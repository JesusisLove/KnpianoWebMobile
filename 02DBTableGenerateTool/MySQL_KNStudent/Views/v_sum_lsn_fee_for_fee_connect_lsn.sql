CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_sum_lsn_fee_for_fee_connect_lsn` AS
    SELECT 
        `v_info_lesson_fee_connect_lsn`.`stu_id` AS `stu_id`,
        `v_info_lesson_fee_connect_lsn`.`stu_name` AS `stu_name`,
        `v_info_lesson_fee_connect_lsn`.`lsn_fee_id` AS `lsn_fee_id`,
        `v_info_lesson_fee_connect_lsn`.`subject_price` AS `subject_price`,
        `v_info_lesson_fee_connect_lsn`.`lesson_type` AS `lesson_type`,
        SUM(`v_info_lesson_fee_connect_lsn`.`lsn_fee`) AS `lsn_fee`,
        `v_info_lesson_fee_connect_lsn`.`lsn_month` AS `lsn_month`
    FROM
        `v_info_lesson_fee_connect_lsn`
    GROUP BY `v_info_lesson_fee_connect_lsn`.`stu_id` , `v_info_lesson_fee_connect_lsn`.`stu_name` , `v_info_lesson_fee_connect_lsn`.`lsn_month` , `v_info_lesson_fee_connect_lsn`.`lsn_fee_id` , `v_info_lesson_fee_connect_lsn`.`subject_price` , `v_info_lesson_fee_connect_lsn`.`lesson_type`