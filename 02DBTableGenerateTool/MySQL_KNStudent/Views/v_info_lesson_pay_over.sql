CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_lesson_pay_over` AS
    SELECT 
        `tpay`.`lsn_pay_id` AS `lsn_pay_id`,
        `vsumfee`.`lsn_fee_id` AS `lsn_fee_id`,
        `vsumfee`.`stu_id` AS `stu_id`,
        `vsumfee`.`stu_name` AS `stu_name`,
        `vsumfee`.`subject_id` AS `subject_id`,
        `vsumfee`.`subject_name` AS `subject_name`,
        `vsumfee`.`subject_sub_id` AS `subject_sub_id`,
        `vsumfee`.`subject_sub_name` AS `subject_sub_name`,
        `vsumfee`.`pay_style` AS `pay_style`,
        `vsumfee`.`lesson_type` AS `lesson_type`,
        `vsumfee`.`lsn_count` AS `lsn_count`,
        `vsumfee`.`lsn_fee` AS `lsn_fee`,
        `tpay`.`lsn_pay` AS `lsn_pay`,
        `bnk`.`bank_id` AS `bank_id`,
        `bnk`.`bank_name` AS `bank_name`,
        `tpay`.`pay_month` AS `pay_month`,
        `tpay`.`pay_date` AS `pay_date`,
        `tpay`.`create_date` AS `create_date`,
        `tpay`.`update_date` AS `update_date`
    FROM
        ((`t_info_lesson_pay` `tpay`
        JOIN `v_info_lesson_sum_fee_pay_over` `vsumfee` ON ((`tpay`.`lsn_fee_id` = `vsumfee`.`lsn_fee_id`)))
        LEFT JOIN `t_mst_bank` `bnk` ON ((`tpay`.`bank_id` = `bnk`.`bank_id`)))