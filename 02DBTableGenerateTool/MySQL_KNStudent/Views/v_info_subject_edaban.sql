-- 学科基本情報マスタ
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_subject_edaban`;
-- 视图-- 不要做驼峰命名变更，为了java程序处理的统一性。
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_subject_edaban` AS
		select eda.subject_id
			  ,sub.subject_name
		      ,eda.subject_sub_id
		      ,eda.subject_sub_name
		      ,eda.subject_price
		      ,eda.del_flg
		      ,eda.create_date
		      ,eda.update_date
		from 
			t_info_subject_edaban eda
		left join
			t_mst_subject sub
		on eda.subject_id = sub.subject_id
		and eda.del_flg = 0
		and sub.del_flg = 0
		;