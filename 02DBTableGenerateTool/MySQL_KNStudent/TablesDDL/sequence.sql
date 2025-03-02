CREATE TABLE `sequence` (
  `seqid` varchar(255) NOT NULL,
  `name` varchar(50) NOT NULL,
  `current_value` int DEFAULT NULL,
  `increment` int DEFAULT '1',
  PRIMARY KEY (`seqid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci