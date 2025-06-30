-- ②未支付学费统计（分组查询月份Only）
-- ③已支付学费统计（分组查询学生，月份）
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_sum_haspaid_lsnfee_by_stu_and_month`;

-- 后台维护用
-- 本视图被下列视图单独调用
   -- v_total_lsnfee_with_paid_unpaid_every_month
   -- v_total_lsnfee_with_paid_unpaid_every_month_every_student
-- ③所有在课学生的每个月已支付状况的分组合计 v_sum_haspaid_lsnfee_by_stu_and_month
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
    GROUP BY stu_id, 
             stu_name, 
             nik_name, 
             lsn_month
    ;
