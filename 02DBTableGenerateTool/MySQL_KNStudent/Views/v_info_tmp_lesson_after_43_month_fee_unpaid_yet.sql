-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_tmp_lesson_after_43_month_fee_unpaid_yet`;
-- 手机前端页面使用
/*
这个视图的前提业务是：按月交费的学生在某月比如10月份完成了规定年度的43节课，那么，43节课是一年12个月的课程，10份就上满了43节课，
这是提前完成了规定课程数，但是11月和12月的课费还没有交，通过执行存储过程(sp_insert_tmp_lesson_info)来给徐你课程表(t_info_lesson_tmp)插入11月和12月的课程信息，
同时也给课费表t_info_lesson_fee插入11月和12月的课费信息，但是这两个月的课费是未支付状态（own_flg=0），
存储过程的执行准备放在Batch系统里执行。每年的12月1号执行这个Batch任务。
这个视图就是用来统计虚拟课程的课费（即，空月按月支付的课费）这些未支付的按月支付课费信息。
*/
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW v_info_tmp_lesson_after_43_month_fee_unpaid_yet AS
/* 
把按月交费的科目做一个统计，月交费场合下的lsn_fee_id lsn_tmp_id是1:n的关系，
此视图是将n个lesson的课时和课费做一个求和统计，
使得lsn_pay_id,lsn_fee_id能清楚地表达出这两个字段的1:1关系
*/
SELECT
    '' as lsn_pay_id,
    fee.lsn_fee_id,  
    tmp.stu_id,
    tmp.stu_name,
    tmp.nik_name,
    tmp.subject_id,
    tmp.subject_name,
    tmp.subject_sub_id,
    tmp.subject_sub_name,
    fee.lsn_fee as subject_price,
    1 as pay_style,
    0 AS lsn_count,
    fee.lsn_fee * 4 as lsn_fee,
    NULL as pay_date,
    1 as lesson_type,
    left(tmp.schedual_date,7) as lsn_month,
    fee.own_flg as own_flg 
FROM 
    v_info_lesson_tmp tmp
INNER JOIN
	t_info_lesson_fee fee
ON tmp.lsn_tmp_id = fee.lesson_id