-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson_sum_fee_pay_over`;
-- 视图 从v_info_lesson_fee_connect_lsn表里每月上完的课数和已支付课费做统计
-- 手机前端页面使用
/* 该视图也被下列视图调用：
		v_info_lesson_pay_over、
		v_sum_haspaid_lsnfee_by_stu_and_month */ 
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER 
VIEW v_info_lesson_sum_fee_pay_over AS
/* 
把按月交费的科目做一个统计，月交费场合下的lsn_fee_id lesson_id是1:n的关系，
此视图是将n个lesson的课时和课费做一个求和统计，
使得lsn_pay_id,lsn_fee_id能清楚地表达出这两个字段的1:1关系
*/
SELECT 
    pay.lsn_pay_id,
    fee.lsn_fee_id,
    fee.stu_id,
    fee.stu_name,
    fee.nik_name,
    fee.subject_id,
    fee.subject_name,
    fee.subject_sub_id,
    fee.subject_sub_name,
    fee.subject_price,
    fee.pay_style,
    SUM(fee.lsn_count) AS lsn_count,
    SUM(fee.lsn_fee) AS lsn_fee, -- 应支付
    SUM(pay.lsn_pay) AS lsn_pay, -- 已支付
    pay.pay_date,
    pay.bank_id,
    fee.lsn_month,
    fee.lsn_month as pay_month,
    fee.lesson_type
FROM 
    (
        SELECT
            lsn_fee_id,
            stu_id,
            stu_name,
            nik_name,
            subject_id,
            subject_name,
            subject_sub_id,
            subject_sub_name,
            subject_price,
            pay_style,
            lesson_type,
            CASE 
                WHEN lesson_type = 1 THEN subject_price * 4
                ELSE SUM(lsn_fee)
            END AS lsn_fee,
            lsn_count,
            lsn_month
        FROM (
            SELECT 
                lsn_fee_id,
                stu_id,
                stu_name,
                nik_name,
                subject_id,
                subject_name,
                subject_sub_id,
                subject_sub_name,
                subject_price,
                pay_style,
                lesson_type,
                SUM(lsn_count) as lsn_count,
                SUM(lsn_fee) as lsn_fee,
                lsn_month
            FROM 
                v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
            WHERE 
                own_flg = 1
            GROUP BY 
                lsn_fee_id, stu_id, stu_name, nik_name, subject_id, subject_name, 
                subject_sub_id, subject_sub_name, lsn_month, subject_price, 
                pay_style, lesson_type
        ) aa
        GROUP BY 
            lsn_fee_id, stu_id, stu_name, nik_name, subject_id, subject_name, 
            subject_sub_id, subject_sub_name, lsn_month, subject_price, 
            pay_style, lesson_type, lsn_count
    ) fee
    INNER JOIN
        t_info_lesson_pay pay
    ON
        fee.lsn_fee_id = pay.lsn_fee_id
GROUP BY 
    pay.lsn_pay_id,
    fee.lsn_fee_id,
    fee.stu_id,
    fee.stu_name,
    fee.nik_name,
    fee.subject_id,
    fee.subject_name,
    fee.subject_sub_id,
    fee.subject_sub_name,
    fee.subject_price,
    fee.pay_style,
    fee.lsn_month,
    pay.pay_date,
    fee.lesson_type
;