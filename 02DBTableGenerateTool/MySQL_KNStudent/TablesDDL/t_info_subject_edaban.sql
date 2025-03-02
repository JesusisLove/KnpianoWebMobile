CREATE TABLE `t_info_subject_edaban` (
  `subject_id` varchar(255) NOT NULL,
  `subject_sub_id` varchar(255) NOT NULL,
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `del_flg` int DEFAULT '0',
  `subject_price` float DEFAULT NULL,
  `subject_sub_name` varchar(20) DEFAULT NULL,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`subject_id`,`subject_sub_id`),
  CONSTRAINT `subject_edaban` FOREIGN KEY (`subject_id`) REFERENCES `t_mst_subject` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci