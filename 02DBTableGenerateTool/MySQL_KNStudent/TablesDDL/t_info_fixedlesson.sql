-- DROP TABLE IF EXISTS `t_info_fixedlesson`;
CREATE TABLE `t_info_fixedlesson` (
  `stu_id` varchar(255) NOT NULL,
  `subject_id` varchar(255) NOT NULL,
  `fixed_week` varchar(255) NOT NULL,
  `fixed_hour` int DEFAULT NULL,
  `fixed_minute` int DEFAULT NULL,
  PRIMARY KEY (`stu_id`,`subject_id`,`fixed_week`),
  KEY `fk_fixedlesson_subject_id_new` (`subject_id`),
  CONSTRAINT `fk_fixedlesson_stu_id` FOREIGN KEY (`stu_id`) REFERENCES `t_mst_student` (`stu_id`),
  CONSTRAINT `fk_fixedlesson_subject_id_new` FOREIGN KEY (`subject_id`) REFERENCES `t_mst_subject` (`subject_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;