-- (学生总综合)所有学生当前年度每月总课费的总支付，未支付状况查询
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS v_total_lsnfee_with_paid_unpaid_every_month;
-- 后台维护用
-- 所有在课学生的每个月总课费，已支付，未支付状况 v_total_lsnfee_with_paid_unpaid_every_month
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_total_lsnfee_with_paid_unpaid_every_month AS
    SELECT 
        SUM(lsn_fee_alias.should_pay_lsn_fee) AS should_pay_lsn_fee,
        SUM(lsn_fee_alias.has_paid_lsn_fee) AS has_paid_lsn_fee,
        SUM(lsn_fee_alias.unpaid_lsn_fee) AS unpaid_lsn_fee,
        lsn_fee_alias.lsn_month AS lsn_month
    FROM
        (SELECT 
            SUM(T1.lsn_fee) AS should_pay_lsn_fee,
            0.0 AS has_paid_lsn_fee,
            0.0 AS unpaid_lsn_fee,
            T1.lsn_month AS lsn_month
        FROM
            -- v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month T1
            v_sum_lsn_fee_for_fee_connect_lsn T1
        GROUP BY T1.lsn_month 
        UNION ALL 
        SELECT 
            0.0 AS should_pay_lsn_fee,
            SUM(T2.lsn_fee) AS has_paid_lsn_fee,
            0.0 AS unpaid_lsn_fee,
            T2.lsn_month AS lsn_month
        FROM
            v_sum_haspaid_lsnfee_by_stu_and_month T2
        GROUP BY T2.lsn_month 
        UNION ALL 
        SELECT 
            0.0 AS should_pay_lsn_fee,
            0.0 AS has_paid_lsn_fee,
            SUM(T3.lsn_fee) AS unpaid_lsn_fee,
            T3.lsn_month AS lsn_month
        FROM
            v_sum_unpaid_lsnfee_by_stu_and_month T3
        GROUP BY T3.lsn_month
        ) lsn_fee_alias
    GROUP BY lsn_fee_alias.lsn_month