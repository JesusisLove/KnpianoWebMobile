DELIMITER //

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_execute_weekly_batch_lsn_schedule`(IN start_date_str VARCHAR(10), IN end_date_str VARCHAR(10), IN SEQCode VARCHAR(20))
BEGIN
    -- 声明常量
    DECLARE PROCEDURE_NAME VARCHAR(100) DEFAULT 'sp_execute_weekly_batch_lsn_schedule';
    DECLARE PROCEDURE_ALIAS_NAME VARCHAR(100) DEFAULT '执行周计划排课处理';

    -- 声明变量用于日志记录
    DECLARE v_step_result VARCHAR(255);
    DECLARE v_current_step VARCHAR(100) DEFAULT '初始化';
    DECLARE v_error_message TEXT;
    DECLARE v_affected_rows INT;

    -- 定义异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
        
        INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
        VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, 
                CONCAT('发生错误: ', v_error_message));
        
        -- 重新抛出错误
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END;

    -- 创建临时表
    SET v_current_step = '创建临时表';
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_date_range (
        date_column DATE,
        weekday_column VARCHAR(20)
    );
    
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

    -- 清空临时表
    SET v_current_step = '清空临时表';
    TRUNCATE TABLE temp_date_range;
    
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

    -- 插入数据
    SET v_current_step = '向临时表插入数据';
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

    SET v_affected_rows = ROW_COUNT();
    SET v_step_result = IF(v_affected_rows > 0, CONCAT('成功: 插入 ', v_affected_rows, ' 行'), '未插入任何行');
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    -- 显示结果
    -- SELECT * FROM temp_date_range;
    -- 根据关联表，将制定日期范围的学生排课信息直接插入到上课信息表【t_info_lesson】的数据
    SET v_current_step = '向t_info_lesson表插入数据';
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

    SET v_affected_rows = ROW_COUNT();
    SET v_step_result = IF(v_affected_rows > 0, CONCAT('成功: 插入 ', v_affected_rows, ' 行'), '未插入任何行');
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    -- 删除临时表
    SET v_current_step = '删除临时表';
    DROP TEMPORARY TABLE IF EXISTS temp_date_range;
    
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

    -- 存储过程完成
    SET v_current_step = '存储过程完成';
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

END //

DELIMITER ;