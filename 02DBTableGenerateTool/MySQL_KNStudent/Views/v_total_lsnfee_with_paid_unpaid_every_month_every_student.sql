-- （学生明细综合）每个学生当前年度每月总课费的总支付，未支付状况查询
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS v_total_lsnfee_with_paid_unpaid_every_month_every_student;
-- 后台维护用
-- 每个学生当前年度每月总课费的总支付，未支付状况查询 v_total_lsnfee_with_paid_unpaid_every_month_every_student
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW v_total_lsnfee_with_paid_unpaid_every_month_every_student AS
    SELECT 
        feeStatus.stu_id AS stu_id,
        feeStatus.stu_name AS stu_name,
        feeStatus.nik_name AS nik_name,
        feeStatus.lsn_month AS lsn_month,
        SUM(feeStatus.should_pay_lsn_fee) AS should_pay_lsn_fee,
        SUM(feeStatus.has_paid_lsn_fee) AS has_paid_lsn_fee,
        SUM(feeStatus.unpaid_lsn_fee) AS unpaid_lsn_fee
    FROM
        (SELECT 
            T1.stu_id AS stu_id,
            T1.stu_name AS stu_name,
            T1.nik_name AS nik_name,
            SUM(T1.lsn_fee) AS should_pay_lsn_fee,
            0.0 AS has_paid_lsn_fee,
            0.0 AS unpaid_lsn_fee,
            T1.lsn_month AS lsn_month
        FROM
            v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month T1
        GROUP BY T1.stu_id , T1.stu_name , T1.nik_name,T1.lsn_month 
        UNION ALL 
        SELECT 
            T2.stu_id AS stu_id,
            T2.stu_name AS stu_name,
            T2.nik_name AS nik_name,
            0.0 AS should_pay_lsn_fee,
            SUM(T2.lsn_pay) AS has_paid_lsn_fee,
            0.0 AS unpaid_lsn_fee,
            T2.lsn_month AS lsn_month
        FROM
            v_sum_haspaid_lsnfee_by_stu_and_month T2
        GROUP BY T2.stu_id , T2.stu_name ,T2.nik_name, T2.lsn_month 
        UNION ALL 
        SELECT 
            T3.stu_id AS stu_id,
            T3.stu_name AS stu_name,
            T3.nik_name AS nik_name,
            0.0 AS should_pay_lsn_fee,
            0.0 AS has_paid_lsn_fee,
            SUM(T3.lsn_fee) AS unpaid_lsn_fee,
            T3.lsn_month AS lsn_month
        FROM
            v_sum_unpaid_lsnfee_by_stu_and_month T3
        GROUP BY T3.stu_id, T3.stu_name, T3.nik_name, T3.lsn_month) feeStatus
    GROUP BY feeStatus.stu_id, feeStatus.stu_name, feeStatus.nik_name, feeStatus.lsn_month;