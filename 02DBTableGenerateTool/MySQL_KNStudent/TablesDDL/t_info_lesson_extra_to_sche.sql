-- DROP TABLE IF EXISTS `t_info_lesson_extra_to_sche`;
/* 添加索引的原由：
对加课换正课的新的课费id做已经支付的更新处理，
由于这个表没有主键，所以程序在执行的时候启动safe update模式（安全更新模式）
没有主键或没有索引，不让更新，索引添加了idx_fee_id_date
*/
CREATE TABLE `t_info_lesson_extra_to_sche` (
  `lesson_id` varchar(45) NOT NULL,
  `old_lsn_fee_id` varchar(255) NOT NULL,
  `new_lsn_fee_id` varchar(255) NOT NULL,
  `old_subject_sub_id` varchar(255) NOT NULL,
  `new_subject_sub_id` varchar(255) NOT NULL,
  `old_lsn_fee` decimal(4,0) DEFAULT NULL,
  `new_lsn_fee` decimal(4,0) DEFAULT NULL,
  `new_scanqr_date` datetime DEFAULT NULL,
  `is_good_change` int DEFAULT NULL,
  `new_own_flg` int DEFAULT '0',
  INDEX idx_fee_id_date (new_lsn_fee_id, new_scanqr_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;