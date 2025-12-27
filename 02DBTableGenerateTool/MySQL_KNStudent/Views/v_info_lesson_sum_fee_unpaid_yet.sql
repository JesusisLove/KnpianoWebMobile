-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson_sum_fee_unpaid_yet`;
-- 📱视图 从v_info_lesson_fee_connect_lsn表里每个每月上完每个科目的课数和未支付课费做统计
-- 手机前端页面使用
/* 该视图被下列视图给调用了
		v_sum_unpaid_lsnfee_by_stu_and_month
 */
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW v_info_lesson_sum_fee_unpaid_yet AS
/* 
把按月交费的科目做一个统计，月交费场合下的lsn_fee_id lesson_id是1:n的关系，
此视图是将n个lesson的课时和课费做一个求和统计，
使得lsn_pay_id,lsn_fee_id能清楚地表达出这两个字段的1:1关系
*/
SELECT
    '' as lsn_pay_id,
    newtmptbl.lsn_fee_id,    -- 明确指定来源
    newtmptbl.stu_id,
    newtmptbl.stu_name,
    newtmptbl.nik_name,
    newtmptbl.subject_id,
    newtmptbl.subject_name,
    newtmptbl.subject_sub_id,
    newtmptbl.subject_sub_name,
    newtmptbl.subject_price,
    newtmptbl.pay_style,
    SUM(newtmptbl.lsn_count) AS lsn_count,
    SUM(CASE 
            WHEN newtmptbl.lesson_type = 1 THEN newtmptbl.subject_price * 4
            ELSE newtmptbl.lsn_fee 
        END) as lsn_fee,
    NULL as pay_date,
    newtmptbl.lesson_type,
    newtmptbl.lsn_month,
    newtmptbl.own_flg 
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
        SUM(lsn_count) AS lsn_count,
        SUM(lsn_fee) as lsn_fee,
        lesson_type,
        lsn_month,
        own_flg 
    FROM 
        v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
    WHERE 
        own_flg = 0
        AND del_flg = 0
    GROUP BY 
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
        lsn_month,
        own_flg
) newtmptbl
GROUP BY 
    newtmptbl.lsn_fee_id,
    newtmptbl.stu_id,
    newtmptbl.stu_name,
    newtmptbl.subject_id,
    newtmptbl.subject_name,
    newtmptbl.subject_sub_id,
    newtmptbl.subject_sub_name,
    newtmptbl.subject_price,
    newtmptbl.pay_style,
    newtmptbl.lesson_type,
    newtmptbl.lsn_month,
    newtmptbl.own_flg;