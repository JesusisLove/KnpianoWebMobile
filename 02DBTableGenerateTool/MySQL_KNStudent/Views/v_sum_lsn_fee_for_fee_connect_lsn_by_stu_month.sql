CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month` AS
    SELECT 
        `aa`.`lsn_fee_id` AS `lsn_fee_id`,
        `aa`.`stu_id` AS `stu_id`,
        `aa`.`stu_name` AS `stu_name`,
        `aa`.`subject_id` AS `subject_id`,
        `aa`.`subject_name` AS `subject_name`,
        `aa`.`subject_sub_id` AS `subject_sub_id`,
        `aa`.`subject_sub_name` AS `subject_sub_name`,
        `aa`.`subject_price` AS `subject_price`,
        `aa`.`pay_style` AS `pay_style`,
        `aa`.`lesson_type` AS `lesson_type`,
        SUM((CASE
            WHEN (`aa`.`lesson_type` = 1) THEN (`aa`.`subject_price` * 4)
            ELSE `aa`.`lsn_fee`
        END)) AS `lsn_fee`,
        `aa`.`lsn_count` AS `lsn_count`,
        `aa`.`lsn_month` AS `lsn_month`
    FROM
        (SELECT 
            `v_info_lesson_fee_connect_lsn`.`lsn_fee_id` AS `lsn_fee_id`,
                `v_info_lesson_fee_connect_lsn`.`stu_id` AS `stu_id`,
                `v_info_lesson_fee_connect_lsn`.`stu_name` AS `stu_name`,
                `v_info_lesson_fee_connect_lsn`.`subject_id` AS `subject_id`,
                `v_info_lesson_fee_connect_lsn`.`subject_name` AS `subject_name`,
                `v_info_lesson_fee_connect_lsn`.`subject_sub_id` AS `subject_sub_id`,
                `v_info_lesson_fee_connect_lsn`.`subject_sub_name` AS `subject_sub_name`,
                `v_info_lesson_fee_connect_lsn`.`subject_price` AS `subject_price`,
                `v_info_lesson_fee_connect_lsn`.`pay_style` AS `pay_style`,
                `v_info_lesson_fee_connect_lsn`.`lesson_type` AS `lesson_type`,
                SUM(`v_info_lesson_fee_connect_lsn`.`lsn_count`) AS `lsn_count`,
                SUM(`v_info_lesson_fee_connect_lsn`.`lsn_fee`) AS `lsn_fee`,
                `v_info_lesson_fee_connect_lsn`.`lsn_month` AS `lsn_month`
        FROM
            `v_info_lesson_fee_connect_lsn`
        GROUP BY `v_info_lesson_fee_connect_lsn`.`lsn_fee_id` , `v_info_lesson_fee_connect_lsn`.`stu_id` , `v_info_lesson_fee_connect_lsn`.`stu_name` , `v_info_lesson_fee_connect_lsn`.`subject_id` , `v_info_lesson_fee_connect_lsn`.`subject_name` , `v_info_lesson_fee_connect_lsn`.`subject_sub_id` , `v_info_lesson_fee_connect_lsn`.`subject_sub_name` , `v_info_lesson_fee_connect_lsn`.`lsn_month` , `v_info_lesson_fee_connect_lsn`.`subject_price` , `v_info_lesson_fee_connect_lsn`.`pay_style` , `v_info_lesson_fee_connect_lsn`.`lesson_type`) `aa`
    GROUP BY `aa`.`lsn_fee_id` , `aa`.`stu_id` , `aa`.`stu_name` , `aa`.`subject_id` , `aa`.`subject_name` , `aa`.`subject_sub_id` , `aa`.`subject_sub_name` , `aa`.`lsn_month` , `aa`.`subject_price` , `aa`.`pay_style` , `aa`.`lesson_type` , `aa`.`lsn_count`