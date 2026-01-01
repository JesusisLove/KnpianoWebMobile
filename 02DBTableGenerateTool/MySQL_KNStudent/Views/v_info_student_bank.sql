-- 銀行基本情報マスタ
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_student_bank`;
-- 视图
CREATE 
	ALGORITHM=UNDEFINED 
	DEFINER=`root`@`%` 
	SQL SECURITY DEFINER 
VIEW `v_info_student_bank` 
AS 
select 
	stubnk.stu_id
   ,stu.stu_name
   ,stubnk.bank_id
   ,bnk.bank_name
   ,stubnk.del_flg
   ,stubnk.create_date
   ,stubnk.update_date
from t_info_student_bank stubnk
left join
t_mst_bank bnk
on stubnk.bank_id = bnk.bank_id 
and bnk.del_flg = 0
left join
t_mst_student stu
on stubnk.stu_id = stu.stu_id
and stu.del_flg = 0
;