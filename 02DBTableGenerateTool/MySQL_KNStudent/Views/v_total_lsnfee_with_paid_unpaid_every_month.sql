CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_total_lsnfee_with_paid_unpaid_every_month` AS
    SELECT 
        SUM(`lsn_fee_alias`.`should_pay_lsn_fee`) AS `should_pay_lsn_fee`,
        SUM(`lsn_fee_alias`.`has_paid_lsn_fee`) AS `has_paid_lsn_fee`,
        SUM(`lsn_fee_alias`.`unpaid_lsn_fee`) AS `unpaid_lsn_fee`,
        `lsn_fee_alias`.`lsn_month` AS `lsn_month`
    FROM
        (SELECT 
            SUM(`v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`.`lsn_fee`) AS `should_pay_lsn_fee`,
                0.0 AS `has_paid_lsn_fee`,
                0.0 AS `unpaid_lsn_fee`,
                `v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`.`lsn_month` AS `lsn_month`
        FROM
            `v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`
        GROUP BY `v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`.`lsn_month` UNION ALL SELECT 
            0.0 AS `should_pay_lsn_fee`,
                SUM(`v_sum_haspaid_lsnfee_by_stu_and_month`.`lsn_fee`) AS `has_paid_lsn_fee`,
                0.0 AS `unpaid_lsn_fee`,
                `v_sum_haspaid_lsnfee_by_stu_and_month`.`lsn_month` AS `lsn_month`
        FROM
            `v_sum_haspaid_lsnfee_by_stu_and_month`
        GROUP BY `v_sum_haspaid_lsnfee_by_stu_and_month`.`lsn_month` UNION ALL SELECT 
            0.0 AS `should_pay_lsn_fee`,
                0.0 AS `has_paid_lsn_fee`,
                SUM(`v_sum_unpaid_lsnfee_by_stu_and_month`.`lsn_fee`) AS `unpaid_lsn_fee`,
                `v_sum_unpaid_lsnfee_by_stu_and_month`.`lsn_month` AS `lsn_month`
        FROM
            `v_sum_unpaid_lsnfee_by_stu_and_month`
        GROUP BY `v_sum_unpaid_lsnfee_by_stu_and_month`.`lsn_month`) `lsn_fee_alias`
    GROUP BY `lsn_fee_alias`.`lsn_month`