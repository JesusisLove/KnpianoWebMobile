CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_lsn_statistics_by_stuid` AS
    SELECT 
        `v_info_lesson_fee_connect_lsn`.`stu_id` AS `stu_id`,
        `v_info_lesson_fee_connect_lsn`.`stu_name` AS `stu_name`,
        `v_info_lesson_fee_connect_lsn`.`subject_name` AS `subject_name`,
        `v_info_lesson_fee_connect_lsn`.`subject_id` AS `subject_id`,
        `v_info_lesson_fee_connect_lsn`.`subject_sub_id` AS `subject_sub_id`,
        `v_info_lesson_fee_connect_lsn`.`subject_sub_name` AS `subject_sub_name`,
        `v_info_lesson_fee_connect_lsn`.`lesson_type` AS `lesson_type`,
        SUM(`v_info_lesson_fee_connect_lsn`.`lsn_count`) AS `lsn_count`,
        `v_info_lesson_fee_connect_lsn`.`lsn_month` AS `lsn_month`
    FROM
        `v_info_lesson_fee_connect_lsn`
    GROUP BY `v_info_lesson_fee_connect_lsn`.`stu_id` , `v_info_lesson_fee_connect_lsn`.`stu_name` , `v_info_lesson_fee_connect_lsn`.`subject_name` , `v_info_lesson_fee_connect_lsn`.`subject_id` , `v_info_lesson_fee_connect_lsn`.`subject_sub_id` , `v_info_lesson_fee_connect_lsn`.`subject_sub_name` , `v_info_lesson_fee_connect_lsn`.`lesson_type` , `v_info_lesson_fee_connect_lsn`.`lsn_month`
    ORDER BY `v_info_lesson_fee_connect_lsn`.`lsn_month` , `v_info_lesson_fee_connect_lsn`.`subject_id` , `v_info_lesson_fee_connect_lsn`.`subject_sub_id`