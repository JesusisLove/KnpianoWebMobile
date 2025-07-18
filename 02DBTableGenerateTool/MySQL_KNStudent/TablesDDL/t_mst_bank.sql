-- DROP TABLE IF EXISTS `t_mst_bank`;
CREATE TABLE `t_mst_bank` (
  `bank_id` varchar(255) NOT NULL,
  `bank_name` varchar(20) NOT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`bank_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;