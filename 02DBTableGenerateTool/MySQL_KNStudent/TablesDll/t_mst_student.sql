CREATE TABLE `t_mst_student` (
  `stu_id` varchar(255) NOT NULL,
  `stu_name` varchar(20) NOT NULL,
  `gender` int DEFAULT NULL,
  `birthday` varchar(10) DEFAULT NULL,
  `address` varchar(64) DEFAULT NULL,
  `post_code` varchar(12) DEFAULT NULL,
  `tel1` varchar(20) DEFAULT NULL,
  `tel2` varchar(20) DEFAULT NULL,
  `tel3` varchar(20) DEFAULT NULL,
  `tel4` varchar(20) DEFAULT NULL,
  `introducer` varchar(20) DEFAULT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`stu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci