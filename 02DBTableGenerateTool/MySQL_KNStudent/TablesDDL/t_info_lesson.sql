-- DROP TABLE IF EXISTS `t_info_lesson`;
CREATE TABLE `t_info_lesson` (
  `lesson_id` varchar(32) NOT NULL,
  `stu_id` varchar(32) DEFAULT NULL,
  `subject_id` varchar(32) DEFAULT NULL,
  `subject_sub_id` varchar(32) DEFAULT NULL,
  `class_duration` int DEFAULT NULL,
  `extra_to_dur_date` datetime(6) DEFAULT NULL,
  `lesson_type` int DEFAULT NULL,
  `schedual_type` int DEFAULT '0',
  `schedual_date` datetime(6) DEFAULT NULL,
  `lsn_adjusted_date` datetime(6) DEFAULT NULL,
  `scanqr_date` datetime(6) DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`lesson_id`),
  KEY `fk_lesson_stu_id` (`stu_id`),
  KEY `fk_lesson_subject_id` (`subject_id`),
  CONSTRAINT `fk_lesson_stu_id` FOREIGN KEY (`stu_id`) REFERENCES `t_mst_student` (`stu_id`),
  CONSTRAINT `fk_lesson_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `t_mst_subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;