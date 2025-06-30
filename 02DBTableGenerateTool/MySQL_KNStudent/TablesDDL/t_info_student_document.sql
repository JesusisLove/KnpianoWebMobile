-- DROP TABLE IF EXISTS `t_info_student_document`;
CREATE TABLE `t_info_student_document` (
  `stu_id` varchar(32) NOT NULL,
  `subject_id` varchar(32) NOT NULL,
  `subject_sub_id` varchar(32) NOT NULL,
  `adjusted_date` date NOT NULL,
  `pay_style` int DEFAULT NULL,
  `minutes_per_lsn` int DEFAULT NULL,
  `lesson_fee` float DEFAULT NULL,
  `lesson_fee_adjusted` float DEFAULT NULL,
  `year_lsn_cnt` int DEFAULT '0',
  `exam_date` date DEFAULT NULL,
  `exam_score` float DEFAULT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`stu_id`,`subject_id`,`subject_sub_id`,`adjusted_date`),
  KEY `fk_subject_id` (`subject_id`),
  CONSTRAINT `fk_student_id` FOREIGN KEY (`stu_id`) REFERENCES `t_mst_student` (`stu_id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `t_mst_subject` (`subject_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;