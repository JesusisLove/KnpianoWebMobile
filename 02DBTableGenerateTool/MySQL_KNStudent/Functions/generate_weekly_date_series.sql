-- 生成星期和日期的列表函数
CREATE DEFINER=`root`@`localhost` FUNCTION `generate_weekly_date_series`(start_date_str VARCHAR(10), end_date_str VARCHAR(10)) RETURNS varchar(4000) CHARSET utf8mb4
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
END