-- 保持日期序列生成函数不变只要一周的表数据信息
DELIMITER //
CREATE FUNCTION generate_weekly_date_series(start_date_str VARCHAR(10), end_date_str VARCHAR(10))
RETURNS VARCHAR(4000)
DETERMINISTIC
BEGIN
    DECLARE date_list VARCHAR(4000);
    DECLARE curr_date DATE;
    DECLARE start_date DATE;
    DECLARE end_date DATE;
    
    SET start_date = STR_TO_DATE(start_date_str, '%Y-%m-%d');
    SET end_date = STR_TO_DATE(end_date_str, '%Y-%m-%d');
    
    SET date_list = '';
    SET curr_date = start_date;
    
    WHILE curr_date <= end_date DO
        SET date_list = CONCAT(date_list, DATE_FORMAT(curr_date, '%Y-%m-%d'), ',');
        SET curr_date = DATE_ADD(curr_date, INTERVAL 1 DAY);
    END WHILE;
    
    RETURN TRIM(TRAILING ',' FROM date_list);
END //
DELIMITER ;

-- 创建一个存储过程来生成日期范围
/**
INPUT：一周的开始日期和一周的结束日期
OUTPUT：生成要插入到上课信息表的一周的结果集
*/
DELIMITER //
CREATE PROCEDURE sp_weekly_batch_lsn_schedule_process(IN start_date_str VARCHAR(10), IN end_date_str VARCHAR(10), IN SEQCode VARCHAR(20))
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
        1 AS schedual_type,
		CONCAT(cdr.date_column, ' ', LPAD(fix.fixed_hour, 2, '0'), ':', LPAD(fix.fixed_minute, 2, '0')) as schedual_date
	FROM 
		t_info_fixedlesson fix -- 一周排课的日期范围
	LEFT JOIN 
		v_latest_subject_info_from_student_document doc -- 学生档案最新正在上课的科目信息
		ON fix.stu_id = doc.stu_id AND fix.subject_id = doc.subject_id
	INNER JOIN 
		temp_date_range cdr
		ON cdr.weekday_column = fix.fixed_week; -- 学生固定排课表
END //
DELIMITER ;


-- 使用示例
-- CALL create_date_range('2024-08-12', '2024-08-18');