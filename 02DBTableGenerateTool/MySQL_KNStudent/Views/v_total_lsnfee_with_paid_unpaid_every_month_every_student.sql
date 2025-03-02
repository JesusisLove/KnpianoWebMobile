use prod_KNStudent;
DROP VIEW IF EXISTS v_total_lsnfee_with_paid_unpaid_every_month_every_student;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_total_lsnfee_with_paid_unpaid_every_month_every_student AS
    SELECT 
        feeStatus.stu_id AS stu_id,
        feeStatus.stu_name AS stu_name,
        SUM(feeStatus.should_pay_lsn_fee) AS should_pay_lsn_fee,
        SUM(feeStatus.has_paid_lsn_fee) AS has_paid_lsn_fee,
        SUM(feeStatus.unpaid_lsn_fee) AS unpaid_lsn_fee,
        feeStatus.lsn_month AS lsn_month
    FROM
        (SELECT 
            T1.stu_id AS stu_id,
            T1.stu_name AS stu_name,
            SUM(T1.lsn_fee) AS should_pay_lsn_fee,
            0.0 AS has_paid_lsn_fee,
            0.0 AS unpaid_lsn_fee,
            T1.lsn_month AS lsn_month
        FROM
            v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month T1
        GROUP BY T1.stu_id , T1.stu_name , T1.lsn_month 
        UNION ALL 
        SELECT 
            T2.stu_id AS stu_id,
            T2.stu_name AS stu_name,
            0.0 AS should_pay_lsn_fee,
            SUM(T2.lsn_fee) AS has_paid_lsn_fee,
            0.0 AS unpaid_lsn_fee,
            T2.lsn_month AS lsn_month
        FROM
            v_sum_haspaid_lsnfee_by_stu_and_month T2
        GROUP BY T2.stu_id , T2.stu_name , T2.lsn_month 
        UNION ALL 
        SELECT 
            T3.stu_id AS stu_id,
                T3.stu_name AS stu_name,
                0.0 AS should_pay_lsn_fee,
                0.0 AS has_paid_lsn_fee,
                SUM(T3.lsn_fee) AS unpaid_lsn_fee,
                T3.lsn_month AS lsn_month
        FROM
            v_sum_unpaid_lsnfee_by_stu_and_month T3
        GROUP BY T3.stu_id , T3.stu_name , T3.lsn_month) feeStatus
    GROUP BY feeStatus.stu_id , feeStatus.stu_name , feeStatus.lsn_month