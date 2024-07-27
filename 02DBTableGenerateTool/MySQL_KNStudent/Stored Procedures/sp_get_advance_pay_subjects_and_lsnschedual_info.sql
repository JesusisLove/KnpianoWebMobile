CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_advance_pay_subjects_and_lsnschedual_info`(IN p_stuId VARCHAR(50), IN p_yearMonth VARCHAR(7))
BEGIN
    DECLARE v_year INT;
    DECLARE v_month INT;
    DECLARE v_first_day DATE;
    
    -- 临时禁用安全更新模式
    SET SQL_SAFE_UPDATES = 0;
    
    -- 确保临时表不存在
    DROP TEMPORARY TABLE IF EXISTS temp_result;
    
    -- 解析年月
    SET v_year = CAST(SUBSTRING(p_yearMonth, 1, 4) AS UNSIGNED);
    SET v_month = CAST(SUBSTRING(p_yearMonth, 6, 2) AS UNSIGNED);
    SET v_first_day = DATE(CONCAT(p_yearMonth, '-01'));

    -- 创建临时表来存储计算后的结果
    CREATE TEMPORARY TABLE temp_result AS
    -- 获取 doc 表中的数据，而这些数据在 lsn 表中不存在
    (SELECT 
        doc.stu_id,
        doc.stu_name,
        doc.subject_id,
        doc.subject_name,
        doc.subject_sub_id,
        doc.subject_sub_name,
        NULL AS schedual_date
    FROM (
        SELECT 
            stu_id,
            stu_name,
            subject_id,
            subject_name,
            subject_sub_id,
            subject_sub_name,
            MAX(schedual_date) AS schedual_date
        FROM v_info_lesson
        WHERE scanQR_date IS NOT NULL
        GROUP BY 
            stu_id,
            stu_name,
            subject_id,
            subject_name,
            subject_sub_id,
            subject_sub_name
    ) lsn
    RIGHT JOIN (
        SELECT *
        FROM v_latest_subject_info_from_student_document
    ) doc
    ON lsn.stu_id = doc.stu_id 
    AND lsn.subject_id = doc.subject_id
    AND lsn.subject_sub_id = doc.subject_sub_id
    WHERE lsn.stu_id IS NULL
      AND doc.stu_id = p_stuId)
    UNION ALL
    (SELECT 
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
        MAX(schedual_date) AS schedual_date
    FROM v_info_lesson
    WHERE stu_id = p_stuId
      AND scanQR_date IS NOT NULL
    GROUP BY 
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name);

    -- 更新 schedual_date
    UPDATE temp_result tr
    LEFT JOIN KNStudent.v_earliest_fixed_week_info AS vefw
    ON tr.stu_id = vefw.stu_id AND tr.subject_id = vefw.subject_id
    SET tr.schedual_date = 
        CASE 
            WHEN vefw.stu_id IS NOT NULL THEN
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

    -- 返回结果
    SELECT * FROM temp_result;

    -- 删除临时表
    DROP TEMPORARY TABLE IF EXISTS temp_result;
    
    -- 重新启用安全更新模式
    SET SQL_SAFE_UPDATES = 1;
END