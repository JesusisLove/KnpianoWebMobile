CREATE TABLE `t_info_lesson_fee` (
  `lsn_fee_id` varchar(255) NOT NULL,
  `lesson_id` varchar(255) NOT NULL,
  `pay_style` int DEFAULT NULL,
  `lsn_fee` float DEFAULT NULL,
  `lsn_month` varchar(7) DEFAULT NULL,
  `own_flg` int DEFAULT '0',
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`lsn_fee_id`,`lesson_id`),
  KEY `fk_lesson_id` (`lesson_id`),
  CONSTRAINT `fk_lesson_id` FOREIGN KEY (`lesson_id`) REFERENCES `t_info_lesson` (`lesson_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci