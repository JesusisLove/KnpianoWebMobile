-- DROP TABLE IF EXISTS `t_fixedlesson_status`;
CREATE TABLE `t_fixedlesson_status` (
  `week_number` int NOT NULL,
  `start_week_date` varchar(10) NOT NULL,
  `end_week_date` varchar(10) NOT NULL,
  `fixed_status` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;