CREATE TABLE `t_info_lesson_extra_to_sche` (
  `lesson_id` varchar(45) NOT NULL,
  `old_lsn_fee_id` varchar(255) NOT NULL,
  `new_lsn_fee_id` varchar(255) NOT NULL,
  `lsn_fee` decimal(4,0) DEFAULT NULL,
  `new_scanqr_date` datetime DEFAULT NULL,
  `is_good_change` int DEFAULT NULL,
  `new_own_flg` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;