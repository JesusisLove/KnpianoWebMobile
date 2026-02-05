DELIMITER //

DROP PROCEDURE IF EXISTS sp_execute_advc_lsn_fee_pay_per_lesson //

CREATE PROCEDURE sp_execute_advc_lsn_fee_pay_per_lesson(
    IN p_stu_id VARCHAR(32),
    IN p_subject_id VARCHAR(32),
    IN p_subject_sub_id VARCHAR(32),
    IN p_lesson_type INT,
    IN p_minutes_per_lsn INT,
    IN p_subject_price DECIMAL(10,2),
    IN p_first_schedual_datetime DATETIME,
    IN p_lesson_count INT,
    IN p_bank_id VARCHAR(32),
    IN p_lsn_seq_code VARCHAR(20),
    IN p_fee_seq_code VARCHAR(20),
    IN p_pay_seq_code VARCHAR(20),
    OUT p_result INT
)
BEGIN
    -- ============================================================
    -- 执行按课时预支付处理
    --
    -- 双指针合并遍历：
    --   数据源1: 固定排课候选日期（每周+7天推算）
    --   数据源2: 既存非固定课程（CURSOR按日期升序）
    -- 按日期顺序合并处理，执行N条有效记录的写入。
    --
    -- 处理模式：
    --   A = 无既存课程 → INSERT lesson + fee + pay + advc_pay（唯一记录到预支付关联表的模式）
    --   B = 未签到既存课程（无fee） → 复用lesson，INSERT fee + pay（不记录advc_pay）
    --   C = 已签到未支付既存课程（有fee，无pay） → 复用lesson+fee，INSERT pay（不记录advc_pay）
    --   D = 已签到已支付 或 已有预支付记录 → 跳过
    -- ============================================================

    -- 声明常量
    DECLARE PROCEDURE_NAME VARCHAR(100) DEFAULT 'sp_execute_advc_lsn_fee_pay_per_lesson';
    DECLARE PROCEDURE_ALIAS_NAME VARCHAR(100) DEFAULT '执行按课时预支付处理';

    DECLARE v_lesson_id VARCHAR(50);
    DECLARE v_lsn_fee_id VARCHAR(50);
    DECLARE v_lsn_pay_id VARCHAR(50);
    DECLARE v_lsn_month VARCHAR(7);
    DECLARE v_next_fixed_date DATETIME;
    DECLARE v_step_result VARCHAR(255);
    DECLARE v_current_step VARCHAR(100) DEFAULT '初始化';
    DECLARE v_error_message TEXT;

    -- 每次迭代用到的变量
    DECLARE v_current_date DATETIME;
    DECLARE v_current_lesson_id VARCHAR(50);
    DECLARE v_current_fee_id VARCHAR(50);
    DECLARE v_exist_count INT;
    DECLARE v_fee_count INT;
    DECLARE v_pay_count INT;
    DECLARE v_advc_count INT;
    DECLARE v_mode VARCHAR(1);

    -- 固定排课时间信息（从传入的第一个排课日期推算）
    DECLARE v_fixed_dayofweek INT;
    DECLARE v_fixed_hour INT;
    DECLARE v_fixed_minute INT;

    -- 循环控制
    DECLARE v_processed_count INT DEFAULT 0;
    DECLARE v_iteration INT DEFAULT 0;
    DECLARE v_max_iteration INT DEFAULT 100;
    DECLARE v_skipped_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;

        SET p_result = 0;
        ROLLBACK;

        INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
        VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step,
                CONCAT('发生错误: ', v_error_message));
    END;

    START TRANSACTION;

    SET v_current_step = '初始化：按课时预支付循环';
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step,
            CONCAT('学生:', p_stu_id, ' 科目:', p_subject_id, ' 课时数:', p_lesson_count));

    -- 从传入的第一个排课日期推算固定排课的星期和时间
    SET v_fixed_dayofweek = DAYOFWEEK(p_first_schedual_datetime);
    SET v_fixed_hour = HOUR(p_first_schedual_datetime);
    SET v_fixed_minute = MINUTE(p_first_schedual_datetime);
    SET v_next_fixed_date = p_first_schedual_datetime;

    -- ============================
    -- 双指针合并遍历循环
    -- 使用嵌套BEGIN...END块隔离CURSOR和CONTINUE HANDLER的作用域，
    -- 防止影响外层的EXIT HANDLER和SELECT INTO语句。
    -- ============================
    BEGIN
        DECLARE v_nfix_done INT DEFAULT 0;
        DECLARE v_nfix_lesson_id VARCHAR(50);
        DECLARE v_nfix_date DATETIME;

        -- 非固定课程游标：查询该学生该科目在第一个固定排课日之后的
        -- 非固定时间点的既存课程，按日期升序
        DECLARE cur_nfix CURSOR FOR
            SELECT lesson_id, schedual_date
            FROM t_info_lesson
            WHERE stu_id = p_stu_id
              AND subject_id = p_subject_id
              AND subject_sub_id = p_subject_sub_id
              AND schedual_date >= p_first_schedual_datetime
              AND del_flg = 0
              AND NOT (
                  DAYOFWEEK(schedual_date) = v_fixed_dayofweek
                  AND HOUR(schedual_date) = v_fixed_hour
                  AND MINUTE(schedual_date) = v_fixed_minute
              )
            ORDER BY schedual_date;

        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_nfix_done = 1;

        -- 打开游标，取出第一条非固定课程
        OPEN cur_nfix;
        FETCH cur_nfix INTO v_nfix_lesson_id, v_nfix_date;

        -- 主循环：双指针合并遍历
        WHILE v_processed_count < p_lesson_count AND v_iteration < v_max_iteration DO

            -- 初始化每次迭代的变量
            SET v_current_lesson_id = NULL;
            SET v_current_fee_id = NULL;
            SET v_current_date = NULL;
            SET v_mode = NULL;

            -- ============================================
            -- 步骤1: 双指针选择下一个要处理的日期
            -- ============================================
            IF v_nfix_done = 0 AND v_nfix_date < v_next_fixed_date THEN
                -- ─── 非固定课程日期更早 → 先处理非固定课程 ───
                SET v_current_date = v_nfix_date;
                SET v_current_lesson_id = v_nfix_lesson_id;

                -- 预取下一条非固定课程（为下次循环做准备）
                FETCH cur_nfix INTO v_nfix_lesson_id, v_nfix_date;

            ELSE
                -- ─── 固定候选日期更早（或非固定已耗尽）→ 处理固定日期 ───
                SET v_current_date = v_next_fixed_date;

                -- 检查该固定日期是否有既存课程
                SELECT COUNT(*) INTO v_exist_count
                FROM t_info_lesson
                WHERE stu_id = p_stu_id
                  AND subject_id = p_subject_id
                  AND subject_sub_id = p_subject_sub_id
                  AND schedual_date = v_next_fixed_date
                  AND del_flg = 0;

                IF v_exist_count > 0 THEN
                    -- 固定日期有既存课程 → 获取lesson_id
                    SELECT lesson_id INTO v_current_lesson_id
                    FROM t_info_lesson
                    WHERE stu_id = p_stu_id
                      AND subject_id = p_subject_id
                      AND subject_sub_id = p_subject_sub_id
                      AND schedual_date = v_next_fixed_date
                      AND del_flg = 0
                    LIMIT 1;
                END IF;
                -- 如果v_exist_count = 0，则v_current_lesson_id仍为NULL → 模式A

                -- 固定日期指针前进+7天
                SET v_next_fixed_date = DATE_ADD(v_next_fixed_date, INTERVAL 7 DAY);
            END IF;

            SET v_lsn_month = DATE_FORMAT(v_current_date, '%Y-%m');

            -- ============================================
            -- 步骤2: 重新判定处理模式（A/B/C/D）
            --         Execution时重新检查，防止T1→T2状态变化
            -- ============================================
            SET v_current_step = CONCAT('迭代', v_iteration + 1, ' 日期:', DATE_FORMAT(v_current_date, '%Y-%m-%d %H:%i'), ' - 状态检查');

            IF v_current_lesson_id IS NULL THEN
                -- 无既存课程（仅固定候选日期会出现此情况）
                SET v_mode = 'A';
            ELSE
                -- 有既存课程 → 进一步判定

                -- 检查是否已有预支付记录
                SELECT COUNT(*) INTO v_advc_count
                FROM t_info_lsn_fee_advc_pay
                WHERE lesson_id = v_current_lesson_id
                  AND del_flg = 0;

                IF v_advc_count > 0 THEN
                    SET v_mode = 'D';  -- 已有预支付记录，跳过
                ELSE
                    -- 检查课费记录
                    SELECT COUNT(*) INTO v_fee_count
                    FROM t_info_lesson_fee
                    WHERE lesson_id = v_current_lesson_id
                      AND pay_style = 0
                      AND del_flg = 0;

                    IF v_fee_count = 0 THEN
                        -- 无课费记录 → 模式B
                        SET v_mode = 'B';
                    ELSE
                        -- 获取fee_id
                        SELECT lsn_fee_id INTO v_current_fee_id
                        FROM t_info_lesson_fee
                        WHERE lesson_id = v_current_lesson_id
                          AND pay_style = 0
                          AND del_flg = 0
                        LIMIT 1;

                        -- 检查支付记录
                        SELECT COUNT(*) INTO v_pay_count
                        FROM t_info_lesson_pay
                        WHERE lsn_fee_id = v_current_fee_id
                          AND del_flg = 0;

                        IF v_pay_count = 0 THEN
                            SET v_mode = 'C';  -- 有fee无pay → 模式C
                        ELSE
                            SET v_mode = 'D';  -- 已支付 → 跳过
                        END IF;
                    END IF;
                END IF;
            END IF;

            -- 记录状态检查结果
            SET v_step_result = CONCAT('模式:', v_mode,
                CASE v_mode
                    WHEN 'A' THEN '(新建全套)'
                    WHEN 'B' THEN CONCAT('(复用lesson:', v_current_lesson_id, ')')
                    WHEN 'C' THEN CONCAT('(复用lesson:', v_current_lesson_id, ' fee:', v_current_fee_id, ')')
                    WHEN 'D' THEN '(跳过-已支付或已预支付)'
                END);
            INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
            VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

            -- ============================================
            -- 步骤3: 根据模式执行操作
            -- ============================================

            IF v_mode = 'D' THEN
                -- 模式D：跳过，不处理
                SET v_skipped_count = v_skipped_count + 1;

            ELSEIF v_mode = 'A' THEN
                -- ===== 模式A：全新创建 lesson + fee + pay + advc_pay =====
                SET v_processed_count = v_processed_count + 1;

                -- A-1: 新建lesson
                SET v_lesson_id = CONCAT(p_lsn_seq_code, nextval(p_lsn_seq_code));
                SET v_current_step = CONCAT('第', v_processed_count, '节(A) - 新建lesson');
                INSERT INTO t_info_lesson (
                    lesson_id, stu_id, subject_id, subject_sub_id,
                    class_duration, lesson_type, schedual_type, schedual_date
                ) VALUES (
                    v_lesson_id, p_stu_id, p_subject_id, p_subject_sub_id,
                    p_minutes_per_lsn, p_lesson_type, 0, v_current_date
                );
                SET v_step_result = CONCAT(IF(ROW_COUNT() > 0, '成功', '失败'), ' lesson_id:', v_lesson_id);
                INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
                VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

                -- A-2: 新建fee
                SET v_lsn_fee_id = CONCAT(p_fee_seq_code, nextval(p_fee_seq_code));
                SET v_current_step = CONCAT('第', v_processed_count, '节(A) - 新建fee');
                INSERT INTO t_info_lesson_fee (
                    lsn_fee_id, lesson_id, pay_style, lsn_fee, lsn_month, own_flg
                ) VALUES (
                    v_lsn_fee_id, v_lesson_id, 0, p_subject_price, v_lsn_month, 1
                );
                SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
                INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
                VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

                -- A-3: 新建pay
                SET v_lsn_pay_id = CONCAT(p_pay_seq_code, nextval(p_pay_seq_code));
                SET v_current_step = CONCAT('第', v_processed_count, '节(A) - 新建pay');
                INSERT INTO t_info_lesson_pay (
                    lsn_pay_id, lsn_fee_id, lsn_pay, bank_id, pay_month, pay_date
                ) VALUES (
                    v_lsn_pay_id, v_lsn_fee_id, p_subject_price, p_bank_id, v_lsn_month, CURDATE()
                );
                SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
                INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
                VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

                -- A-4: 新建advc_pay（仅A模式记录到预支付关联表）
                SET v_current_step = CONCAT('第', v_processed_count, '节(A) - 新建advc_pay');
                INSERT INTO t_info_lsn_fee_advc_pay (
                    lesson_id, lsn_fee_id, lsn_pay_id, advance_pay_date
                ) VALUES (
                    v_lesson_id, v_lsn_fee_id, v_lsn_pay_id, CURDATE()
                );
                SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
                INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
                VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

            ELSEIF v_mode = 'B' THEN
                -- ===== 模式B：复用lesson，新建 fee + pay（不记录advc_pay） =====
                SET v_processed_count = v_processed_count + 1;
                SET v_lesson_id = v_current_lesson_id;

                -- B-1: 新建fee（lesson_id复用既存）
                SET v_lsn_fee_id = CONCAT(p_fee_seq_code, nextval(p_fee_seq_code));
                SET v_current_step = CONCAT('第', v_processed_count, '节(B) - 复用lesson:', v_lesson_id, ' 新建fee');
                INSERT INTO t_info_lesson_fee (
                    lsn_fee_id, lesson_id, pay_style, lsn_fee, lsn_month, own_flg
                ) VALUES (
                    v_lsn_fee_id, v_lesson_id, 0, p_subject_price, v_lsn_month, 1
                );
                SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
                INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
                VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

                -- B-2: 新建pay
                SET v_lsn_pay_id = CONCAT(p_pay_seq_code, nextval(p_pay_seq_code));
                SET v_current_step = CONCAT('第', v_processed_count, '节(B) - 新建pay');
                INSERT INTO t_info_lesson_pay (
                    lsn_pay_id, lsn_fee_id, lsn_pay, bank_id, pay_month, pay_date
                ) VALUES (
                    v_lsn_pay_id, v_lsn_fee_id, p_subject_price, p_bank_id, v_lsn_month, CURDATE()
                );
                SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
                INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
                VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

                -- B-3: 不记录advc_pay（模式B不是真正的预支付，仅A模式记录到预支付关联表）

            ELSEIF v_mode = 'C' THEN
                -- ===== 模式C：复用lesson+fee，新建 pay（不记录advc_pay，实质是补缴） =====
                SET v_processed_count = v_processed_count + 1;
                SET v_lesson_id = v_current_lesson_id;
                SET v_lsn_fee_id = v_current_fee_id;

                -- C-1: 新建pay（lesson_id和lsn_fee_id复用既存）
                SET v_lsn_pay_id = CONCAT(p_pay_seq_code, nextval(p_pay_seq_code));
                SET v_current_step = CONCAT('第', v_processed_count, '节(C) - 复用lesson:', v_lesson_id, ' fee:', v_lsn_fee_id, ' 新建pay');
                INSERT INTO t_info_lesson_pay (
                    lsn_pay_id, lsn_fee_id, lsn_pay, bank_id, pay_month, pay_date
                ) VALUES (
                    v_lsn_pay_id, v_lsn_fee_id, p_subject_price, p_bank_id, v_lsn_month, CURDATE()
                );
                SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
                INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
                VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

                -- C-2: 不记录advc_pay（模式C是补缴，不是预支付，仅A模式记录到预支付关联表）

            END IF;

            SET v_iteration = v_iteration + 1;

        END WHILE;

        CLOSE cur_nfix;
    END;

    COMMIT;
    SET p_result = 1;

    SET v_current_step = '存储过程完成';
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step,
            CONCAT('成功：共处理', v_processed_count, '节课，跳过', v_skipped_count, '节(已支付/已预支付)，遍历', v_iteration, '次'));

END //

DELIMITER ;
