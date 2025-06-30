-- DROP TABLE IF EXISTS `t_info_lsn_fee_advc_pay`;
CREATE TABLE `t_info_lsn_fee_advc_pay` (
  `lesson_id` varchar(32) NOT NULL,
  `lsn_fee_id` varchar(32) NOT NULL,
  `lsn_pay_id` varchar(32) NOT NULL,
  `advance_pay_date` datetime DEFAULT NULL,
  `advc_flg` int DEFAULT '0',
  `del_flg` int DEFAULT '0',
  `create_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_date` datetime DEFAULT NULL,
  PRIMARY KEY (`lsn_pay_id`,`lsn_fee_id`,`lesson_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;