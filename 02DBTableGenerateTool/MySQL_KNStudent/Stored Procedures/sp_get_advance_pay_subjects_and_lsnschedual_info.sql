DELIMITER //

DROP PROCEDURE IF EXISTS sp_get_advance_pay_subjects_and_lsnschedual_info //

CREATE PROCEDURE sp_get_advance_pay_subjects_and_lsnschedual_info(IN p_stuId VARCHAR(32), IN p_yearMonth VARCHAR(7))
BEGIN
    DECLARE v_year INT;
    DECLARE v_month INT;
    DECLARE v_first_day DATE;
    DECLARE v_yearMonth VARCHAR(7);
    
    -- 临时禁用安全更新模式，以允许不使用主键的更新操作
    SET SQL_SAFE_UPDATES = 0;
    
    -- 确保临时表不存在，防止重复创建错误
    DROP TEMPORARY TABLE IF EXISTS temp_result;

    -- 创建临时表来存储计算后的结果
    CREATE TEMPORARY TABLE temp_result AS
    -- 第一部分：获取学生档案中存在但在课程信息表中不存在的科目数据
    (SELECT 
        doc.stu_id,
        doc.stu_name,
        doc.subject_id,
        doc.subject_name,
        doc.subject_sub_id,
        doc.subject_sub_name,
        -- 根据支付方式设置课程类型
        CASE 
            WHEN doc.pay_style = 1 THEN 1  -- 1表示按月付费的情况下，有月计划课和月加课，月加课是此次处理的对象外课程
            --  WHEN doc.pay_style = 0 THEN 0  -- 0表示课时结算的课程
        END as lesson_type,
        NULL AS schedual_date
    FROM (
        -- 子查询：获取每个学生每个科目的最新签到日期，月加课（lesson_type != 2）
        SELECT 
            stu_id,
            stu_name,
            subject_id,
            subject_name,
            subject_sub_id,
            subject_sub_name,
            lesson_type,
            MAX(schedual_date) AS schedual_date
        FROM v_info_lesson
        WHERE scanQR_date IS NOT NULL and lesson_type != 2
        GROUP BY 
            stu_id,
            stu_name,
            subject_id,
            subject_name,
            subject_sub_id,
            lesson_type,
            subject_sub_name
    ) lsn
    RIGHT JOIN (
        -- 从学生档案表获取所有课程记录
        SELECT *
        FROM v_latest_subject_info_from_student_document
    ) doc
    ON lsn.stu_id = doc.stu_id 
    AND lsn.subject_id = doc.subject_id
    AND lsn.subject_sub_id = doc.subject_sub_id
    WHERE lsn.stu_id IS NULL AND doc.pay_style = 1
      AND doc.stu_id = p_stuId)
    UNION ALL
    -- 第二部分：获取学生在课程信息表中的现有课程数据
    (SELECT 
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
        lesson_type,
        MAX(schedual_date) AS schedual_date
    FROM v_info_lesson
    WHERE stu_id = p_stuId
      AND scanQR_date IS NOT NULL -- 获取每个学生每个科目的最新签到日期
      and lesson_type = 1 -- 这次预支付课费先只考虑月计划课的Pattern吧lesson_type !=2  -- 排除月加课
    GROUP BY 
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        lesson_type,
        subject_sub_name);

    -- 从schedual_date中提取年月信息，并计算下一个月
    -- 如果schedual_date为空，则使用传入的p_yearMonth参数
    IF EXISTS (SELECT 1 FROM temp_result WHERE schedual_date IS NOT NULL AND schedual_date >= CURDATE()) THEN
        SELECT 
            YEAR(DATE_ADD(MAX(schedual_date), INTERVAL 1 MONTH)),
            MONTH(DATE_ADD(MAX(schedual_date), INTERVAL 1 MONTH)),
            DATE(DATE_FORMAT(DATE_ADD(MAX(schedual_date), INTERVAL 1 MONTH), '%Y-%m-01')),
            DATE_FORMAT(DATE_ADD(MAX(schedual_date), INTERVAL 1 MONTH), '%Y-%m')
        INTO
            v_year, v_month, v_first_day, v_yearMonth
        FROM temp_result
        WHERE schedual_date IS NOT NULL;
    ELSE
        SET v_year = SUBSTRING(p_yearMonth, 1, 4);
        SET v_month = SUBSTRING(p_yearMonth, 6, 2);
        SET v_first_day = DATE(CONCAT(p_yearMonth, '-01'));
        SET v_yearMonth = p_yearMonth;
    END IF;

    -- 更新临时表中的排课计划日期
    UPDATE temp_result tr
    LEFT JOIN KNStudent.v_earliest_fixed_week_info AS vefw
    ON tr.stu_id = vefw.stu_id AND tr.subject_id = vefw.subject_id
    SET tr.schedual_date = 
        CASE 
            WHEN vefw.stu_id IS NOT NULL THEN
                -- 复杂的日期计算逻辑，用于确定给定月份中每个课程的第一个上课日期
                DATE_FORMAT(
                    DATE_ADD(
                        v_first_day,
                        INTERVAL (
                            CASE 
                                WHEN DAYOFWEEK(v_first_day) > CASE vefw.fixed_week
                                                                WHEN 'Mon' THEN 2
                                                                WHEN 'Tue' THEN 3
                                                                WHEN 'Wed' THEN 4
                                                                WHEN 'Thu' THEN 5
                                                                WHEN 'Fri' THEN 6
                                                                WHEN 'Sat' THEN 7
                                                                WHEN 'Sun' THEN 1
                                                              END
                                THEN 7 + CASE vefw.fixed_week
                                            WHEN 'Mon' THEN 0
                                            WHEN 'Tue' THEN 1
                                            WHEN 'Wed' THEN 2
                                            WHEN 'Thu' THEN 3
                                            WHEN 'Fri' THEN 4
                                            WHEN 'Sat' THEN 5
                                            WHEN 'Sun' THEN 6
                                          END - DAYOFWEEK(v_first_day) + 2
                                ELSE CASE vefw.fixed_week
                                        WHEN 'Mon' THEN 0
                                        WHEN 'Tue' THEN 1
                                        WHEN 'Wed' THEN 2
                                        WHEN 'Thu' THEN 3
                                        WHEN 'Fri' THEN 4
                                        WHEN 'Sat' THEN 5
                                        WHEN 'Sun' THEN 6
                                     END - DAYOFWEEK(v_first_day) + 2
                            END
                        ) DAY
                    ),
                    CONCAT('%Y-%m-%d ', LPAD(vefw.fixed_hour, 2, '0'), ':', LPAD(vefw.fixed_minute, 2, '0'))
                )
            ELSE tr.schedual_date
        END
    WHERE tr.stu_id = p_stuId;

    -- 返回计算后结果:以该生目前最后一次的签到月份为基准，预支付该月以后月份的预支付课费
    -- 如果adv.schedual_date有值，表示该科目在固定排课表里有固定的排课记录
    -- 如果adv.schedual_date为空，表示该科目在固定排课表里还没有固定排课记录，仅此而已
    SELECT 
        adv.stu_id,
        adv.stu_name,
        adv.subject_id,
        adv.subject_name,
        adv.subject_sub_id,
        adv.subject_sub_name,
        adv.lesson_type,
        adv.schedual_date,
        vldoc.lesson_fee as subject_price,
        vldoc.minutes_per_lsn
    FROM temp_result adv
    INNER JOIN v_latest_subject_info_from_student_document vldoc
    ON adv.stu_id = vldoc.stu_id
    AND adv.subject_id = vldoc.subject_id
    AND adv.subject_sub_id = vldoc.subject_sub_id;

    -- 清理：删除临时表
    DROP TEMPORARY TABLE IF EXISTS temp_result;
    
    -- 重新启用安全更新模式
    SET SQL_SAFE_UPDATES = 1;
END //

DELIMITER ;

-- 调用存储过程的示例
-- CALL sp_get_advance_pay_subjects_and_lsnschedual_info('kn-stu-3', '2024-08');