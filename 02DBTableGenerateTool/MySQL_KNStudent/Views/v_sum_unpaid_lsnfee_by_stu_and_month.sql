CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_sum_unpaid_lsnfee_by_stu_and_month` AS
    SELECT 
        `v_info_lesson_sum_fee_unpaid_yet`.`stu_id` AS `stu_id`,
        `v_info_lesson_sum_fee_unpaid_yet`.`stu_name` AS `stu_name`,
        SUM(`v_info_lesson_sum_fee_unpaid_yet`.`lsn_fee`) AS `lsn_fee`,
        `v_info_lesson_sum_fee_unpaid_yet`.`lsn_month` AS `lsn_month`
    FROM
        `v_info_lesson_sum_fee_unpaid_yet`
    GROUP BY `v_info_lesson_sum_fee_unpaid_yet`.`stu_id` , `v_info_lesson_sum_fee_unpaid_yet`.`stu_name` , `v_info_lesson_sum_fee_unpaid_yet`.`lsn_month`