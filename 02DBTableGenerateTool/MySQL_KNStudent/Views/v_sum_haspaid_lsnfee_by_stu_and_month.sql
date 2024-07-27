CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_sum_haspaid_lsnfee_by_stu_and_month` AS
    SELECT 
        `v_info_lesson_sum_fee_pay_over`.`stu_id` AS `stu_id`,
        `v_info_lesson_sum_fee_pay_over`.`stu_name` AS `stu_name`,
        SUM(`v_info_lesson_sum_fee_pay_over`.`lsn_fee`) AS `lsn_fee`,
        `v_info_lesson_sum_fee_pay_over`.`lsn_month` AS `lsn_month`
    FROM
        `v_info_lesson_sum_fee_pay_over`
    GROUP BY `v_info_lesson_sum_fee_pay_over`.`stu_id` , `v_info_lesson_sum_fee_pay_over`.`stu_name` , `v_info_lesson_sum_fee_pay_over`.`lsn_month`