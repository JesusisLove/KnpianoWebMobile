use prod_KNStudent;
-- 前提条件，加课换正课执行完了，换正课的lesson_id会将t_info_lesson_fee表中的该记录的del_flg更新为0
-- 同时，会在t_info_lesson_extra_to_sche中,记录原来的lsn_fee_id和换正课后所在月份的新的lsn_fee_id
-- 该视图就是将原来的课费信息和换正课后的课费信息进行了重新整合。
DROP VIEW IF EXISTS v_info_lesson_fee_include_extra2sche;
CREATE VIEW v_info_lesson_fee_include_extra2sche AS 
select 
	lsn_fee_id,
    lesson_id,
    pay_style,
    lsn_fee,
    lsn_month,
    own_flg,
    0 as del_flg,
    0 as extra2sche_flg, -- 正常课程标识
    create_date,
    update_date
from t_info_lesson_fee 
where del_flg = 0
union all
select 
	ext.new_lsn_fee_id as lsn_fee_id,
    fee.lesson_id,
    fee.pay_style,
    -- fee.lsn_fee,
    ext.new_lsn_fee as lsn_fee, -- 如果遇上换正课的那个月份的子科目和该加课的子科目不一致（例如，2024年12月是钢琴5级的课程，换正课到2025年1月，但是1月份开始学6级的课程，那么加课的课程属性就随换正课的课程属性走（即，换正课后的级别就是6级，课费按6级课费走）
    substring(ext.new_scanqr_date,1,7) as lsn_month,
    ext.new_own_flg as own_flg,
    0 as del_flg,
    1 as extra2sche_flg, -- 加课换正课标识
    fee.create_date,
    fee.update_date
from 
t_info_lesson_fee fee
inner join
t_info_lesson_extra_to_sche ext
on fee.lesson_id = ext.lesson_id
and fee.del_flg = 1
;