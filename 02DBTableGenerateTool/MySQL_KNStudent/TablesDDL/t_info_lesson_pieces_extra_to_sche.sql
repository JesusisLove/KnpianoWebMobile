-- 建立零碎的加课换正课中间表
-- USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_lesson_pieces_extra_to_sche`;
/* 添加索引的原由：
对加课换正课的新的课费id做已经支付的更新处理，
由于这个表没有主键，所以程序在执行的时候启动safe update模式（安全更新模式）
没有主键或没有索引，不让更新，索引添加了idx_fee_id_date
*/
CREATE TABLE t_info_lesson_pieces_extra_to_sche (
  lesson_id varchar(32) NOT NULL,
  old_lesson_id varchar(32) NOT NULL,
  own_flg INT DEFAULT 0,
PRIMARY KEY (lesson_id,old_lesson_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;