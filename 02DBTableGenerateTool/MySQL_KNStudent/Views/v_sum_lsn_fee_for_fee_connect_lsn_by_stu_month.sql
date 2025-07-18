-- ④对课费管理视图的学费（已支付未支付都包括在内）的总计算按学生按月的分组查询
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`;
-- 后台维护用
-- 本视图被下列视图单独调用
	-- v_total_lsnfee_with_paid_unpaid_every_month 
	-- v_total_lsnfee_with_paid_unpaid_every_month_every_student
-- ④对课费管理视图的学费（已支付未支付都包括在内）的总计算按学生按月的分组查询 v_sum_lsn_fee_for_fee_connect_lsn
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month AS
    SELECT 
        aa.lsn_fee_id AS lsn_fee_id,
        aa.stu_id AS stu_id,
        aa.stu_name AS stu_name,
        aa.nik_name AS nik_name,
        aa.subject_id AS subject_id,
        aa.subject_name AS subject_name,
        aa.subject_sub_id AS subject_sub_id,
        aa.subject_sub_name AS subject_sub_name,
        aa.subject_price AS subject_price,
        aa.pay_style AS pay_style,
        aa.lesson_type AS lesson_type,
        CASE  
            WHEN (aa.lesson_type = 1) THEN (aa.subject_price * 4)
            ELSE SUM(aa.lsn_fee)
        END as lsn_fee,
        aa.lsn_count AS lsn_count,
        aa.lsn_month AS lsn_month
    FROM
        (SELECT 
            T1.lsn_fee_id AS lsn_fee_id,
            T1.stu_id AS stu_id,
            T1.stu_name AS stu_name,
            T1.nik_name AS nik_name,
            T1.subject_id AS subject_id,
            T1.subject_name AS subject_name,
            T1.subject_sub_id AS subject_sub_id,
            T1.subject_sub_name AS subject_sub_name,
            T1.subject_price AS subject_price,
            T1.pay_style AS pay_style,
            T1.lesson_type AS lesson_type,
            SUM(T1.lsn_count) AS lsn_count,
            SUM(T1.lsn_fee) AS lsn_fee,
            T1.lsn_month AS lsn_month
        FROM
            v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect T1
        GROUP BY 
            T1.lsn_fee_id, T1.stu_id, T1.stu_name, T1.nik_name, T1.subject_id, 
            T1.subject_name, T1.subject_sub_id, T1.subject_sub_name, T1.lsn_month, 
            T1.subject_price, T1.pay_style, T1.lesson_type
        ) aa
    GROUP BY 
        aa.lsn_fee_id, aa.stu_id, aa.stu_name, aa.nik_name, aa.subject_id, 
        aa.subject_name, aa.subject_sub_id, aa.subject_sub_name, aa.lsn_month, 
        aa.subject_price, aa.pay_style, aa.lesson_type, aa.lsn_count;