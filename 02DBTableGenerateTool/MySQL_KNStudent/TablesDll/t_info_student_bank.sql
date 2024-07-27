CREATE TABLE `t_info_student_bank` (
  `bank_id` varchar(255) NOT NULL,
  `stu_id` varchar(255) NOT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`bank_id`,`stu_id`),
  KEY `fk_bank_stu_id` (`stu_id`),
  CONSTRAINT `fk_bank_bank_id` FOREIGN KEY (`bank_id`) REFERENCES `t_mst_bank` (`bank_id`),
  CONSTRAINT `fk_bank_stu_id` FOREIGN KEY (`stu_id`) REFERENCES `t_mst_student` (`stu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci