DROP VIEW IF EXISTS `v_info_lesson_pay_over`;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_lesson_pay_over` AS
    SELECT 
        `vsumfee`.`lsn_pay_id` AS `lsn_pay_id`,
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
        `bnk`.`bank_id` AS `bank_id`,
        `bnk`.`bank_name` AS `bank_name`,
        `vsumfee`.`lsn_month` AS `pay_month`,
        `vsumfee`.`pay_date` AS `pay_date`
    FROM
          `v_info_lesson_sum_fee_pay_over` `vsumfee` 
        left JOIN `t_mst_bank` `bnk` ON (`vsumfee`.`bank_id` = `bnk`.`bank_id`)