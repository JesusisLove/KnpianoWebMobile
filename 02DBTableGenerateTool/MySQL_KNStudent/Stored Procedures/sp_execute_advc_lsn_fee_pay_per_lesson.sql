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
    -- 从 p_first_schedual_datetime 开始逐周遍历候选日期，
    -- 对每个日期重新检查课程状态，根据模式A/B/C/D执行不同操作。
    -- 遍历直到处理了 p_lesson_count 条有效记录（跳过模式D）。
    --
    -- 处理模式：
    --   A = 无既存课程 → INSERT lesson + fee + pay + advc_pay
    --   B = 未签到既存课程（无fee） → 复用lesson，INSERT fee + pay + advc_pay
    --   C = 已签到未支付既存课程（有fee，无pay） → 复用lesson+fee，INSERT pay + advc_pay
    --   D = 已签到已支付 或 已有预支付记录 → 跳过
    -- ============================================================

    -- 声明常量
    DECLARE PROCEDURE_NAME VARCHAR(100) DEFAULT 'sp_execute_advc_lsn_fee_pay_per_lesson';
    DECLARE PROCEDURE_ALIAS_NAME VARCHAR(100) DEFAULT '执行按课时预支付处理';

    DECLARE v_lesson_id VARCHAR(50);
    DECLARE v_lsn_fee_id VARCHAR(50);
    DECLARE v_lsn_pay_id VARCHAR(50);
    DECLARE v_lsn_month VARCHAR(7);
    DECLARE v_schedual_date DATETIME;
    DECLARE v_step_result VARCHAR(255);
    DECLARE v_current_step VARCHAR(100) DEFAULT '初始化';
    DECLARE v_error_message TEXT;

    -- 状态检查用变量
    DECLARE v_existing_lesson_id VARCHAR(50);
    DECLARE v_existing_fee_id VARCHAR(50);
    DECLARE v_scanqr_date DATETIME;
    DECLARE v_lesson_exists INT;
    DECLARE v_fee_count INT;
    DECLARE v_pay_count INT;
    DECLARE v_advc_count INT;
    DECLARE v_mode VARCHAR(1);

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

    -- 从传入的第一个排课日期开始遍历
    SET v_schedual_date = p_first_schedual_datetime;

    -- 遍历候选日期，直到处理了N条有效记录
    WHILE v_processed_count < p_lesson_count AND v_iteration < v_max_iteration DO

        SET v_lsn_month = DATE_FORMAT(v_schedual_date, '%Y-%m');

        -- 初始化每次迭代的变量
        SET v_existing_lesson_id = NULL;
        SET v_existing_fee_id = NULL;
        SET v_scanqr_date = NULL;
        SET v_lesson_exists = 0;
        SET v_fee_count = 0;
        SET v_pay_count = 0;
        SET v_advc_count = 0;
        SET v_mode = NULL;

        -- ===== 步骤1: 检查该候选日期的课程状态 =====
        SET v_current_step = CONCAT('迭代', v_iteration + 1, ' 日期:', DATE_FORMAT(v_schedual_date, '%Y-%m-%d %H:%i'), ' - 状态检查');

        SELECT COUNT(*) INTO v_lesson_exists
        FROM t_info_lesson
        WHERE stu_id = p_stu_id
          AND subject_id = p_subject_id
          AND subject_sub_id = p_subject_sub_id
          AND schedual_date = v_schedual_date
          AND del_flg = 0;

        IF v_lesson_exists = 0 THEN
            -- ===== 模式A：无既存课程 =====
            SET v_mode = 'A';
        ELSE
            -- 获取既存课程信息
            SELECT lesson_id, scanqr_date
            INTO v_existing_lesson_id, v_scanqr_date
            FROM t_info_lesson
            WHERE stu_id = p_stu_id
              AND subject_id = p_subject_id
              AND subject_sub_id = p_subject_sub_id
              AND schedual_date = v_schedual_date
              AND del_flg = 0
            LIMIT 1;

            -- 检查是否已有预支付记录
            SELECT COUNT(*) INTO v_advc_count
            FROM t_info_lsn_fee_advc_pay
            WHERE lesson_id = v_existing_lesson_id
              AND del_flg = 0;

            IF v_advc_count > 0 THEN
                SET v_mode = 'D';  -- 已有预支付记录，跳过
            ELSE
                -- 检查课费记录
                SELECT COUNT(*) INTO v_fee_count
                FROM t_info_lesson_fee
                WHERE lesson_id = v_existing_lesson_id
                  AND pay_style = 0
                  AND del_flg = 0;

                IF v_fee_count = 0 THEN
                    -- 无课费记录 → 模式B
                    SET v_mode = 'B';
                ELSE
                    -- 获取fee_id
                    SELECT lsn_fee_id INTO v_existing_fee_id
                    FROM t_info_lesson_fee
                    WHERE lesson_id = v_existing_lesson_id
                      AND pay_style = 0
                      AND del_flg = 0
                    LIMIT 1;

                    -- 检查支付记录
                    SELECT COUNT(*) INTO v_pay_count
                    FROM t_info_lesson_pay
                    WHERE lsn_fee_id = v_existing_fee_id
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
                WHEN 'B' THEN CONCAT('(复用lesson:', v_existing_lesson_id, ')')
                WHEN 'C' THEN CONCAT('(复用lesson:', v_existing_lesson_id, ' fee:', v_existing_fee_id, ')')
                WHEN 'D' THEN '(跳过-已支付或已预支付)'
            END);
        INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
        VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

        -- ===== 步骤2: 根据模式执行操作 =====

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
                p_minutes_per_lsn, p_lesson_type, 0, v_schedual_date
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

            -- A-4: 新建advc_pay
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
            -- ===== 模式B：复用lesson，新建 fee + pay + advc_pay =====
            SET v_processed_count = v_processed_count + 1;
            SET v_lesson_id = v_existing_lesson_id;

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

            -- B-3: 新建advc_pay
            SET v_current_step = CONCAT('第', v_processed_count, '节(B) - 新建advc_pay');
            INSERT INTO t_info_lsn_fee_advc_pay (
                lesson_id, lsn_fee_id, lsn_pay_id, advance_pay_date
            ) VALUES (
                v_lesson_id, v_lsn_fee_id, v_lsn_pay_id, CURDATE()
            );
            SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
            INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
            VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

        ELSEIF v_mode = 'C' THEN
            -- ===== 模式C：复用lesson+fee，新建 pay + advc_pay =====
            SET v_processed_count = v_processed_count + 1;
            SET v_lesson_id = v_existing_lesson_id;
            SET v_lsn_fee_id = v_existing_fee_id;

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

            -- C-2: 新建advc_pay
            SET v_current_step = CONCAT('第', v_processed_count, '节(C) - 新建advc_pay');
            INSERT INTO t_info_lsn_fee_advc_pay (
                lesson_id, lsn_fee_id, lsn_pay_id, advance_pay_date
            ) VALUES (
                v_lesson_id, v_lsn_fee_id, v_lsn_pay_id, CURDATE()
            );
            SET v_step_result = IF(ROW_COUNT() > 0, '成功', '失败');
            INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
            VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

        END IF;

        -- 移动到下一个候选日期（+7天）
        SET v_schedual_date = DATE_ADD(v_schedual_date, INTERVAL 7 DAY);
        SET v_iteration = v_iteration + 1;

    END WHILE;

    COMMIT;
    SET p_result = 1;

    SET v_current_step = '存储过程完成';
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step,
            CONCAT('成功：共处理', v_processed_count, '节课，跳过', v_skipped_count, '节(已支付/已预支付)，遍历', v_iteration, '次'));

END //

DELIMITER ;
