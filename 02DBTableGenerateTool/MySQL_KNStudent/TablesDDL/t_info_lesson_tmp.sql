
-- DROP TABLE IF EXISTS `t_info_lesson_tmp`;
CREATE TABLE `t_info_lesson_tmp` (
  `lsn_tmp_id` VARCHAR(32) NOT NULL,
  `stu_id` VARCHAR(32) NULL,
  `subject_id` VARCHAR(32) NULL,
  `subject_sub_id` VARCHAR(32) NULL,
  `schedual_date` DATETIME NULL,
  `scanqr_date` DATETIME NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`lsn_tmp_id`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='临时课程表（课费信息存储在t_info_lesson_fee表中）';