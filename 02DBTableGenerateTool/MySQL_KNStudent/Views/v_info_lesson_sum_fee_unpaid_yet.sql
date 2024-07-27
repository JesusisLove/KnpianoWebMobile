CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_lesson_sum_fee_unpaid_yet` AS
    SELECT 
        '' AS `lsn_pay_id`,
        `newtmptbl`.`lsn_fee_id` AS `lsn_fee_id`,
        `newtmptbl`.`stu_id` AS `stu_id`,
        `newtmptbl`.`stu_name` AS `stu_name`,
        `newtmptbl`.`subject_id` AS `subject_id`,
        `newtmptbl`.`subject_name` AS `subject_name`,
        `newtmptbl`.`subject_sub_id` AS `subject_sub_id`,
        `newtmptbl`.`subject_sub_name` AS `subject_sub_name`,
        `newtmptbl`.`subject_price` AS `subject_price`,
        `newtmptbl`.`pay_style` AS `pay_style`,
        SUM(`newtmptbl`.`lsn_count`) AS `lsn_count`,
        SUM((CASE
            WHEN (`newtmptbl`.`lesson_type` = 1) THEN (`newtmptbl`.`subject_price` * 4)
            ELSE `newtmptbl`.`lsn_fee`
        END)) AS `lsn_fee`,
        NULL AS `pay_date`,
        `newtmptbl`.`lesson_type` AS `lesson_type`,
        `newtmptbl`.`lsn_month` AS `lsn_month`,
        `newtmptbl`.`own_flg` AS `own_flg`
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
                SUM(`v_info_lesson_fee_connect_lsn`.`lsn_count`) AS `lsn_count`,
                SUM(`v_info_lesson_fee_connect_lsn`.`lsn_fee`) AS `lsn_fee`,
                `v_info_lesson_fee_connect_lsn`.`lesson_type` AS `lesson_type`,
                `v_info_lesson_fee_connect_lsn`.`lsn_month` AS `lsn_month`,
                `v_info_lesson_fee_connect_lsn`.`own_flg` AS `own_flg`
        FROM
            `v_info_lesson_fee_connect_lsn`
        WHERE
            ((`v_info_lesson_fee_connect_lsn`.`own_flg` = 0)
                AND (`v_info_lesson_fee_connect_lsn`.`del_flg` = 0))
        GROUP BY `v_info_lesson_fee_connect_lsn`.`lsn_fee_id` , `v_info_lesson_fee_connect_lsn`.`stu_id` , `v_info_lesson_fee_connect_lsn`.`stu_name` , `v_info_lesson_fee_connect_lsn`.`subject_id` , `v_info_lesson_fee_connect_lsn`.`subject_name` , `v_info_lesson_fee_connect_lsn`.`subject_sub_id` , `v_info_lesson_fee_connect_lsn`.`subject_sub_name` , `v_info_lesson_fee_connect_lsn`.`subject_price` , `v_info_lesson_fee_connect_lsn`.`pay_style` , `v_info_lesson_fee_connect_lsn`.`lesson_type` , `v_info_lesson_fee_connect_lsn`.`lsn_month` , `v_info_lesson_fee_connect_lsn`.`own_flg`) `newTmpTbl`
    GROUP BY `newtmptbl`.`lsn_fee_id` , `newtmptbl`.`stu_id` , `newtmptbl`.`stu_name` , `newtmptbl`.`subject_id` , `newtmptbl`.`subject_name` , `newtmptbl`.`subject_sub_id` , `newtmptbl`.`subject_sub_name` , `newtmptbl`.`subject_price` , `newtmptbl`.`pay_style` , `newtmptbl`.`lesson_type` , `newtmptbl`.`lsn_month` , `newtmptbl`.`own_flg`