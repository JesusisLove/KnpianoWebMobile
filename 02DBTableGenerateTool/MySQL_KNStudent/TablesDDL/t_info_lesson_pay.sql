-- DROP TABLE IF EXISTS `t_info_lesson_pay`;
CREATE TABLE `t_info_lesson_pay` (
  `lsn_pay_id` varchar(255) NOT NULL,
  `lsn_fee_id` varchar(255) NOT NULL,
  `lsn_pay` float DEFAULT NULL,
  `bank_id` varchar(32) DEFAULT NULL,
  `pay_month` varchar(7) DEFAULT NULL,
  `pay_date` datetime DEFAULT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`lsn_pay_id`,`lsn_fee_id`),
  KEY `fk_lsn_fee_id` (`lsn_fee_id`),
  KEY `fk_bank_id` (`bank_id`),
  CONSTRAINT `fk_bank_id` FOREIGN KEY (`bank_id`) REFERENCES `t_mst_bank` (`bank_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;