CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_weekly_batch_lsn_schedule_process`(IN start_date_str VARCHAR(10), IN end_date_str VARCHAR(10), IN SEQCode VARCHAR(20))
BEGIN
    -- 创建临时表
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_date_range (
        date_column DATE,
        weekday_column VARCHAR(20)
    );

    -- 清空临时表
    TRUNCATE TABLE temp_date_range;

    -- 插入数据
    INSERT INTO temp_date_range (date_column, weekday_column)
    SELECT 
        STR_TO_DATE(date_column, '%Y-%m-%d') AS date_column,
        DATE_FORMAT(STR_TO_DATE(date_column, '%Y-%m-%d'), '%a') AS weekday_column
    FROM (
        SELECT DISTINCT
            SUBSTRING_INDEX(SUBSTRING_INDEX(generate_weekly_date_series(start_date_str, end_date_str), ',', numbers.n), ',', -1) AS date_column
        FROM (
            SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
            UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
            UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
            UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14
        ) numbers
    ) date_range;

    -- 显示结果
    -- SELECT * FROM temp_date_range;
    -- 根据关联表，将制定日期范围的学生排课信息直接插入到上课信息表【t_info_lesson】的数据
	INSERT INTO t_info_lesson (lesson_id,subject_id,subject_sub_id,stu_id,class_duration,lesson_type,schedual_type,schedual_date)
    SELECT 
		CONCAT(SEQCode, nextval(SEQCode)) as lesson_id,
        fix.subject_id,
        doc.subject_sub_id,
		fix.stu_id,
		doc.minutes_per_lsn as class_duration,
		CASE 
			WHEN doc.pay_style = 0 THEN 0
			WHEN doc.pay_style = 1 THEN 1
		END AS lesson_type,
        1 as schedual_type,
		CONCAT(cdr.date_column, ' ', LPAD(fix.fixed_hour, 2, '0'), ':', LPAD(fix.fixed_minute, 2, '0')) as schedual_date
	FROM 
		t_info_fixedlesson fix -- 一周排课的日期范围
	LEFT JOIN 
		v_latest_subject_info_from_student_document doc -- 学生档案最新正在上课的科目信息
		ON fix.stu_id = doc.stu_id AND fix.subject_id = doc.subject_id
	INNER JOIN 
		temp_date_range cdr
		ON cdr.weekday_column = fix.fixed_week; -- 学生固定排课表
END