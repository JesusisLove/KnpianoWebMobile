CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_sum_haspaid_lsnfee_by_stu_and_month AS
    SELECT 
        stu_id AS stu_id,
        stu_name AS stu_name,
        nik_name AS nik_name,
        SUM(lsn_fee) AS lsn_fee,
        lsn_month AS lsn_month
    FROM
        v_info_lesson_sum_fee_pay_over
    GROUP BY stu_id , stu_name , nik_name, lsn_month
    ;
