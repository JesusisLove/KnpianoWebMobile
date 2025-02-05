-- /////TABFLE///////////////////////////////////////////////////////////////////////////////
USE prod_KNStudent;
-- Tables
DROP TABLE IF EXISTS `sequence`;
DROP TABLE IF EXISTS `t_sp_execution_log`;
DROP TABLE IF EXISTS `t_info_lsn_fee_advc_pay`;
DROP TABLE IF EXISTS `t_info_lesson_pay`;
DROP TABLE IF EXISTS `t_info_lesson_fee`;
DROP TABLE IF EXISTS `t_info_lesson`;
DROP TABLE IF EXISTS `t_info_student_document`;
DROP TABLE IF EXISTS `t_info_fixedlesson`;
DROP TABLE IF EXISTS `t_info_student_bank`;
DROP TABLE IF EXISTS `t_fixedlesson_status`;
DROP TABLE IF EXISTS `t_info_subject_edaban`;
DROP TABLE IF EXISTS `t_mst_bank`;
DROP TABLE IF EXISTS `t_mst_subject`;
DROP TABLE IF EXISTS `t_mst_student`;
DROP TABLE IF EXISTS `t_info_lesson_extra_to_sche`;

-- Views
DROP VIEW IF EXISTS `v_info_subject_edaban`;
DROP VIEW IF EXISTS `v_info_student_bank`;
DROP VIEW IF EXISTS `v_info_fixedlesson`;
DROP VIEW IF EXISTS `v_info_student_document`;
DROP VIEW IF EXISTS `v_latest_subject_info_from_student_document`;
DROP VIEW IF EXISTS `v_earliest_fixed_week_info`;
DROP VIEW IF EXISTS `v_info_lesson`;
DROP VIEW IF EXISTS `v_info_lsn_statistics_by_stuid`;
DROP VIEW IF EXISTS `v_info_lesson_fee_connect_lsn`;
DROP VIEW IF EXISTS `v_info_lesson_sum_fee_unpaid_yet`;
DROP VIEW IF EXISTS `v_info_lesson_sum_fee_pay_over`;
DROP VIEW IF EXISTS `v_info_lesson_pay_over`;
DROP VIEW IF EXISTS `v_sum_unpaid_lsnfee_by_stu_and_month`;
DROP VIEW IF EXISTS `v_sum_haspaid_lsnfee_by_stu_and_month`;
DROP VIEW IF EXISTS `v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`;
DROP VIEW IF EXISTS `v_total_lsnfee_with_paid_unpaid_every_month`;
DROP VIEW IF EXISTS `v_total_lsnfee_with_paid_unpaid_every_month_every_student`;
DROP VIEW IF EXISTS `v_info_lesson_fee_include_extra2sche`;
DROP VIEW IF EXISTS `v_info_all_extra_lsns`;

-- Functions
DROP FUNCTION IF EXISTS `currval`;
DROP FUNCTION IF EXISTS `nextval`;
DROP FUNCTION IF EXISTS `setval`;
DROP FUNCTION IF EXISTS `generate_weekly_date_series`;

-- Triggers
DROP TRIGGER IF EXISTS `before_update_t_mst_student`;
DROP TRIGGER IF EXISTS `before_update_t_mst_subject`;
DROP TRIGGER IF EXISTS `before_update_t_info_subject_edaban`;
DROP TRIGGER IF EXISTS `before_update_t_mst_bank`;
DROP TRIGGER IF EXISTS `before_update_t_info_student_bank`;
DROP TRIGGER IF EXISTS `before_update_t_info_student_document`;
DROP TRIGGER IF EXISTS `before_update_t_info_lesson`;
DROP TRIGGER IF EXISTS `before_update_t_info_lesson_fee`;
DROP TRIGGER IF EXISTS `before_update_t_info_lesson_pay`;

-- Procedures
DROP PROCEDURE IF EXISTS `sp_weekly_batch_lsn_schedule_process`;
DROP PROCEDURE IF EXISTS `sp_sum_unpaid_lsnfee_by_stu_and_month`;
DROP PROCEDURE IF EXISTS `sp_get_advance_pay_subjects_and_lsnschedual_info`;
DROP PROCEDURE IF EXISTS `sp_execute_weekly_batch_lsn_schedule`;
DROP PROCEDURE IF EXISTS `sp_execute_advc_lsn_fee_pay`;

-- 00採番テーブル定義
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `sequence`;
CREATE TABLE `sequence` (
  `seqid` varchar(255) NOT NULL,
  `name` varchar(50) NOT NULL,
  `current_value` int DEFAULT NULL,
  `increment` int DEFAULT '1',
  PRIMARY KEY (`seqid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

USE prod_KNStudent;
INSERT INTO sequence VALUES ('kn-stu-','学生番号',   0, 1);
INSERT INTO sequence VALUES ('kn-sub-','学科番号',   0, 1);
INSERT INTO sequence VALUES ('kn-sub-eda-','学科枝番',   0, 1);
INSERT INTO sequence VALUES ('kn-bnk-','銀行番号',   0, 1);
INSERT INTO sequence VALUES ('kn-lsn-','授業番号',   0, 1);
INSERT INTO sequence VALUES ('kn-fee-','課費番号',   0, 1);
INSERT INTO sequence VALUES ('kn-pay-','精算番号',   0, 1);

-- 01学生基本情報マスタ
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_mst_student`;
CREATE TABLE `t_mst_student` (
  `stu_id` varchar(255) NOT NULL,
  `stu_name` varchar(56) NOT NULL,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 02学科基本情報マスタ
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_mst_subject`;
CREATE TABLE `t_mst_subject` (
  `subject_id` varchar(255) NOT NULL,
  `subject_name` varchar(20) NOT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 科目子表
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_subject_edaban`;
CREATE TABLE `t_info_subject_edaban` (
  `subject_id` varchar(255) NOT NULL,
  `subject_sub_id` varchar(255) NOT NULL,
  `subject_sub_name` varchar(20) DEFAULT NULL,
  `subject_price` float DEFAULT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  CONSTRAINT subject_edaban FOREIGN KEY (subject_id) REFERENCES t_mst_subject(subject_id),
  PRIMARY KEY (`subject_id`,`subject_sub_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 03銀行基本情報マスタ
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_mst_bank`;
CREATE TABLE `t_mst_bank` (
  `bank_id` varchar(255) NOT NULL,
  `bank_name` varchar(20) NOT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`bank_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_student_bank`;
CREATE TABLE `t_info_student_bank` (
  `bank_id` varchar(255) NOT NULL,
  `stu_id` varchar(255) NOT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`bank_id`,`stu_id`),
  CONSTRAINT fk_bank_stu_id FOREIGN KEY (stu_id) REFERENCES t_mst_student(stu_id),
  CONSTRAINT fk_bank_bank_id FOREIGN KEY (bank_id) REFERENCES t_mst_bank(bank_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 10学生固定授業計画管理
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_fixedlesson`;
CREATE TABLE `t_info_fixedlesson` (
  `stu_id` varchar(255) NOT NULL,
  `subject_id` varchar(255) NOT NULL,
  `fixed_week` varchar(255) NOT NULL,
  `fixed_hour` int DEFAULT NULL,
  `fixed_minute` int DEFAULT NULL,
  PRIMARY KEY (`stu_id`,`subject_id`,`fixed_week`),
  KEY `fk_fixedlesson_subject_id` (`subject_id`),
  CONSTRAINT `fk_fixedlesson_stu_id` FOREIGN KEY (`stu_id`) REFERENCES `t_mst_student` (`stu_id`),
  CONSTRAINT `fk_fixedlesson_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `t_mst_subject` (`subject_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 11学生歴史ドキュメント情報
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_student_document`;
CREATE TABLE `t_info_student_document` (
  `stu_id` varchar(32) NOT NULL,
  `subject_id` varchar(32) NOT NULL,
  `subject_sub_id` varchar(32) NOT NULL,
  `adjusted_date` date NOT NULL,
  `pay_style` int DEFAULT NULL,
  `minutes_per_lsn` int DEFAULT NULL,
  `lesson_fee` float DEFAULT NULL,
  `lesson_fee_adjusted` float DEFAULT NULL,
  `exam_date` date DEFAULT NULL,
  `exam_score` float DEFAULT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`stu_id`,`subject_id`,`subject_sub_id`,`adjusted_date`),
  KEY `fk_subject_id` (`subject_id`),
  CONSTRAINT `fk_student_id` FOREIGN KEY (`stu_id`) REFERENCES `t_mst_student` (`stu_id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `t_mst_subject` (`subject_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 说明：加上foreign key制约，为了保证主从表数据的完整性，当删除主表的学生或科目的时候，
-- 用foreign key来保证因从表有记录而不能随便删除主表与从表有关联关系的数据

-- 12学生授業情報管理
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_lesson`;
CREATE TABLE `t_info_lesson` (
  `lesson_id` varchar(32) NOT NULL,
  `stu_id` varchar(32) DEFAULT NULL,
  `subject_id` varchar(32) DEFAULT NULL,
  `subject_sub_id` varchar(32) DEFAULT NULL,
  `class_duration` int DEFAULT NULL,
  `extra_to_dur_date` datetime(6) DEFAULT NULL,
  `lesson_type` int DEFAULT NULL,
  `schedual_type` int DEFAULT '0',
  `schedual_date` datetime(6) DEFAULT NULL,
  `lsn_adjusted_date` datetime(6) DEFAULT NULL,
  `scanqr_date` datetime(6) DEFAULT NULL,
  `memo` varchar(255) DEFAULT NULL,
  `del_flg` int DEFAULT '0',
  `create_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `update_date` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`lesson_id`),
  KEY `fk_lesson_stu_id` (`stu_id`),
  KEY `fk_lesson_subject_id` (`subject_id`),
  KEY `fk_stu_document_subject_id` (`subject_id`),
  CONSTRAINT `fk_lesson_stu_id` FOREIGN KEY (`stu_id`) REFERENCES `t_mst_student` (`stu_id`),
  CONSTRAINT `fk_lesson_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `t_mst_subject` (`subject_id`),
  CONSTRAINT `fk_stu_document_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `t_info_student_cocument` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
;

-- 21授業料金情報管理
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_lesson_fee`;
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 22授業課費精算管理
USE prod_KNStudent;
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
  KEY `fk_bank_id` (`bank_id`),
  KEY `fk_lsn_fee_id` (`lsn_fee_id`),
  CONSTRAINT `fk_bank_id` FOREIGN KEY (`bank_id`) REFERENCES `t_mst_bank` (`bank_id`) ON DELETE RESTRICT
  /*
   CONSTRAINT `fk_bank_id` FOREIGN KEY (`bank_id`) REFERENCES `t_mst_bank` (`bank_id`) ON DELETE RESTRICT,
   CONSTRAINT `fk_lsn_fee_id` FOREIGN KEY (`lsn_fee_id`) REFERENCES `t_info_lesson_fee` (`lsn_fee_id`) ON DELETE RESTRICT
   Error Code: 6125. Failed to add the foreign key constraint. Missing unique key for constraint 'fk_lsn_fee_id' in the referenced table 't_info_lesson_fee
   因为lsn_fee_id不是t_info_lesson_fee表里的唯一主键，所以设置外健约束会出错号是6125的错误。
   对策：暂时先把它comment out。
  */
  
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 23年度星期生成表
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_fixedlesson_status`;
CREATE TABLE `t_fixedlesson_status` (
  `week_number` int NOT NULL,
  `start_week_date` varchar(10) NOT NULL,
  `end_week_date` varchar(10) NOT NULL,
  `fixed_status` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 24课费预支付管理表
USE prod_KNStudent;
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


-- 建立调用课费预支付存储过程日志表
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_sp_execution_log`;
CREATE TABLE t_sp_execution_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    procedure_name VARCHAR(100),
    procedure_alias_name VARCHAR(100),
    step_name VARCHAR(100),
    result VARCHAR(255),
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 建立加课换正课中间表
USE prod_KNStudent;
-- DROP TABLE IF EXISTS `t_info_lesson_extra_to_sche`;
/* 添加索引的原由：
对加课换正课的新的课费id做已经支付的更新处理，
由于这个表没有主键，所以程序在执行的时候启动safe update模式（安全更新模式）
没有主键或没有索引，不让更新，索引添加了idx_fee_id_date
*/
CREATE TABLE `t_info_lesson_extra_to_sche` (
  `lesson_id` varchar(45) NOT NULL,
  `old_lsn_fee_id` varchar(255) NOT NULL,
  `new_lsn_fee_id` varchar(255) NOT NULL,
  `lsn_fee` decimal(4,0) DEFAULT NULL,
  `new_scanqr_date` datetime DEFAULT NULL,
  `is_good_change` int DEFAULT NULL,
  `new_own_flg` int DEFAULT '0',
  INDEX idx_fee_id_date (new_lsn_fee_id, new_scanqr_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- ///// VIEW ///////////////////////////////////////////////////////////////////////////////
-- 02学科基本情報マスタ
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_subject_edaban`;
-- 视图-- 不要做驼峰命名变更，为了java程序处理的统一性。
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_subject_edaban` AS
		select eda.subject_id
			  ,sub.subject_name
		      ,eda.subject_sub_id
		      ,eda.subject_sub_name
		      ,eda.subject_price
		      ,eda.del_flg
		      ,eda.create_date
		      ,eda.update_date
		from 
			t_info_subject_edaban eda
		left join
			t_mst_subject sub
		on eda.subject_id = sub.subject_id
		and eda.del_flg = 0
		and sub.del_flg = 0
		;

-- 03銀行基本情報マスタ
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_student_bank`;
-- 视图
CREATE 
	ALGORITHM=UNDEFINED 
	DEFINER=`root`@`localhost` 
	SQL SECURITY DEFINER 
VIEW `v_info_student_bank` 
AS 
select 
	stubnk.stu_id
   ,stu.stu_name
   ,stubnk.bank_id
   ,bnk.bank_name
   ,stubnk.del_flg
   ,stubnk.create_date
   ,stubnk.update_date
from t_info_student_bank stubnk
left join
t_mst_bank bnk
on stubnk.bank_id = bnk.bank_id 
and bnk.del_flg = 0
left join
t_mst_student stu
on stubnk.stu_id = stu.stu_id
and stu.del_flg = 0
;

-- 10学生固定授業計画管理
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_fixedlesson`;
-- 不要做驼峰命名变更，为了java程序处理的统一性。
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_fixedlesson` AS
    SELECT 
        `a`.`stu_id` AS `stu_id`,
        `b`.`stu_name` AS `stu_name`,
        `a`.`subject_id` AS `subject_id`,
        `c`.`subject_name` AS `subject_name`,
        `a`.`fixed_week` AS `fixed_week`,
        `a`.`fixed_hour` AS `fixed_hour`,
        `a`.`fixed_minute` AS `fixed_minute`
    FROM
        ((`t_info_fixedlesson` `a`
        LEFT JOIN `t_mst_student` `b` ON ((`a`.`stu_id` = `b`.`stu_id`)))
        LEFT JOIN `t_mst_subject` `c` ON ((`a`.`subject_id` = `c`.`subject_id`)))
;

-- 11学生歴史ドキュメント情報
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_student_document`;
-- 视图 不要做驼峰命名变更，为了java程序处理的统一性。
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_student_document` AS
    SELECT 
        `doc`.`stu_id` AS `stu_id`,
        `stu`.`stu_name` AS `stu_name`,
        `doc`.`subject_id` AS `subject_id`,
        `jct`.`subject_name` AS `subject_name`,
        `doc`.`subject_sub_id` AS `subject_sub_id`,
        `sub`.`subject_sub_name` AS `subject_sub_name`,
        `doc`.`adjusted_date` AS `adjusted_date`,
        `doc`.`pay_style` AS `pay_style`,
        `doc`.`minutes_per_lsn` AS `minutes_per_lsn`,
        `doc`.`lesson_fee` AS `lesson_fee`,
        `doc`.`lesson_fee_adjusted` AS `lesson_fee_adjusted`,
        `doc`.`del_flg` AS `del_flg`,
        `doc`.`create_date` AS `create_date`,
        `doc`.`update_date` AS `update_date`
    FROM
        (((`t_info_student_document` `doc`
        LEFT JOIN `t_mst_student` `stu` ON ((`doc`.`stu_id` = `stu`.`stu_id`)))
        LEFT JOIN `t_mst_subject` `jct` ON ((`doc`.`subject_id` = `jct`.`subject_id`)))
        LEFT JOIN `v_info_subject_edaban` `sub` ON (((`doc`.`subject_sub_id` = `sub`.`subject_sub_id`)
            AND (`doc`.`subject_id` = `sub`.`subject_id`))))
    ;


USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_earliest_fixed_week_info`;
/* 给AI的提示词：
这是t_info_fixedlesson中stu_id是，'kn-stu-3'的结果集，这个条件下的结果集里，
你看kn-sub-20的记录，有2条记录，从fixed_week字段上看有“Fri”和“Thu”，因为Thu比Fri早，所以kn-sub-20的记录中“Thu”的这条记录是我要的记录，同理，
你看kn-sub-22的记录，有2条记录，从fixed_week字段上看有“Tue”和“Wed”，因为Tue比Wed早，所以kn-sub-22的记录中“Tue”的这条记录是我要的记录，同理，
你看kn-sub-6的记录，有3条记录，从fixed_week字段上看有“Mon”和“Tue”和“Thu”，因为这三个星期中“Mon”是最早的，所以kn-sub-6的记录中“Mon”的这条记录是我要的记录，
同样道理，如果换成stu_id是其他的学生编号，也是按照这个要求，在他的当前科目中找出星期最早的那个记录显示出来。
理解了我的要求了吗？请你按照我的要求给我写一个Mysql的Sql语句。
*/
CREATE VIEW v_earliest_fixed_week_info AS
SELECT 
    t1.stu_id AS stu_id,
    t1.subject_id AS subject_id,
    t1.fixed_week AS fixed_week,
    t1.fixed_hour AS fixed_hour,
    t1.fixed_minute AS fixed_minute
FROM
    (t_info_fixedlesson t1
    JOIN 
    (SELECT 
			stu_id AS stu_id,
            subject_id AS subject_id,
            MIN((CASE
                WHEN (fixed_week = 'Mon') THEN 1
                WHEN (fixed_week = 'Tue') THEN 2
                WHEN (fixed_week = 'Wed') THEN 3
                WHEN (fixed_week = 'Thu') THEN 4
                WHEN (fixed_week = 'Fri') THEN 5
                WHEN (fixed_week = 'Sat') THEN 6
                WHEN (fixed_week = 'Sun') THEN 7
            END)) AS min_day_num
    FROM
        t_info_fixedlesson
    WHERE
        subject_id IS NOT NULL
    GROUP BY stu_id , subject_id
    ) t2 
    ON t1.stu_id = t2.stu_id AND t1.subject_id = t2.subject_id)
WHERE
    (CASE
        WHEN (t1.fixed_week = 'Mon') THEN 1
        WHEN (t1.fixed_week = 'Tue') THEN 2
        WHEN (t1.fixed_week = 'Wed') THEN 3
        WHEN (t1.fixed_week = 'Thu') THEN 4
        WHEN (t1.fixed_week = 'Fri') THEN 5
        WHEN (t1.fixed_week = 'Sat') THEN 6
        WHEN (t1.fixed_week = 'Sun') THEN 7
    END) = t2.min_day_num
ORDER BY t1.stu_id , t1.subject_id;


USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_latest_subject_info_from_student_document`;
-- 视图 从v_info_student_document里抽出学生最新正在上课的科目信息且
-- 不包括预先调整的科目信息（即大于系统当前日期yyyy-MM-dd的预设科目，比如，A学生目前在学习钢琴3级，下月进入钢琴4级，所以下月的4级的科目信息不应该抽出来）
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER 
VIEW v_latest_subject_info_from_student_document AS 
select subquery.stu_id AS stu_id,
       case when subquery.del_flg = 1 then  CONCAT(subquery.stu_name, '(已退学)')
            else subquery.stu_name
       end AS stu_name,
       subquery.subject_id AS subject_id,
       subquery.subject_name AS subject_name,
       subquery.subject_sub_id AS subject_sub_id,
       subquery.subject_sub_name AS subject_sub_name,
       subquery.lesson_fee AS lesson_fee,
       subquery.lesson_fee_adjusted AS lesson_fee_adjusted,
       subquery.minutes_per_lsn AS minutes_per_lsn,
       subquery.pay_style AS pay_style, 
       subquery.adjusted_date AS adjusted_date
from (
    select vDoc.stu_id AS stu_id,
            vDoc.stu_name AS stu_name,
            vDoc.subject_id AS subject_id,
            vDoc.subject_name AS subject_name,
            vDoc.subject_sub_id AS subject_sub_id,
            vDoc.subject_sub_name AS subject_sub_name,
            vDoc.adjusted_date AS adjusted_date,
            vDoc.pay_style AS pay_style,
            vDoc.minutes_per_lsn AS minutes_per_lsn,
            vDoc.lesson_fee AS lesson_fee,
            vDoc.lesson_fee_adjusted AS lesson_fee_adjusted,
            vDoc.del_flg AS del_flg,
            vDoc.create_date AS create_date,
            vDoc.update_date AS update_date,
            row_number() OVER (
                                PARTITION BY vDoc.stu_id,
                                            vDoc.subject_id 
                                            ORDER BY vDoc.adjusted_date desc 
                            )  AS rn 
    from v_info_student_document vDoc
    ) subquery 
where subquery.rn = 1
-- 价格调整日期小于系统当前日期，防止学生下一学期调整的科目不合时机的出现
and subquery.adjusted_date < CURDATE()
;


-- 12学生授業情報管理
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson`;
-- 视图
CREATE VIEW v_info_lesson AS
SELECT 
    a.lesson_id,
    a.subject_id,
    c.subject_name,
    a.subject_sub_id,
    c.subject_sub_name,
    a.stu_id,
    b.stu_name,
    a.class_duration,
    a.lesson_type,
    a.schedual_type,
    a.schedual_date,
    a.scanQR_date,
    a.lsn_adjusted_date,
    a.extra_to_dur_date,
    a.del_flg,
    a.create_date,
    a.update_date
FROM  
    (`t_info_lesson` `a`
        LEFT JOIN `t_mst_student` `b` ON (`a`.`stu_id` = `b`.`stu_id`))
        LEFT JOIN `v_info_subject_edaban` `c` ON (`a`.`subject_id` = `c`.`subject_id` and `a`.`subject_sub_id` = `c`.`subject_sub_id`);

/**
*视图v_info_lesson_include_extra2sche是在v_info_lesson视图的代码基础上作成的，该视图
*只针对加课换成了正课后，对加课换正课的那个记录进行了处理，
*执行视图v_info_lesson，可以看到换正课之前,该月加课记录的真实样貌（相当于姑娘结婚前在娘家的样貌）
*执行v_info_lesson_include_extra2sche，只能看到加课换成正课之后，变成正课的样貌（相当于姑娘结婚后在婆家的样貌）
*该视图只针对加课换正课的数据处理，对其调课记录，正课记录没有影响。
*/
DROP VIEW IF EXISTS v_info_lesson_include_extra2sche;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_info_lesson_include_extra2sche AS
    SELECT 
        lsn.lesson_id AS lesson_id,
        lsn.subject_id AS subject_id,
        eda.subject_name AS subject_name,
        lsn.subject_sub_id AS subject_sub_id,
        eda.subject_sub_name AS subject_sub_name,
        lsn.stu_id AS stu_id,
        case when mst.del_flg = 1 then  CONCAT(mst.stu_name, '(已退学)')
             else mst.stu_name
        end AS stu_name,
        lsn.class_duration AS class_duration,
        lsn.schedual_type AS schedual_type,
        case 
			when lsn.extra_to_dur_date is not null -- 如果该记录是加课换正课记录
            then  lsn.extra_to_dur_date
            else lsn.schedual_date
        end as schedual_date,
        case 
			when lsn.extra_to_dur_date is not null -- 如果该记录是加课换正课记录
            then null -- 成了正课记录的情况下，就让调课日期为null，这样手机页面的加课换正课记录就不会再显示调课日期了👍
            else lsn.lsn_adjusted_date
		end AS lsn_adjusted_date,
        lsn.scanqr_date,
		case 
			when lsn.extra_to_dur_date is not null  -- 如果该记录是加课换正课记录 -- 加课换正课的场合，记住原来真正签到的日期
            then 
				case
					when lsn_adjusted_date is not null
                    then lsn_adjusted_date -- 调课日期是原来实际的上课日期
                    else schedual_date     -- 计划日期是原来实际的上课日期
				end
        end as original_schedual_date,
        case 
			when extra_to_dur_date is not null  -- 如果该记录是加课换正课记录
            then 1 -- 加课换正课的场合，因为已经成为其他日期的正课，所以强行成为正课区分
            else lsn.lesson_type -- 上记以外的场合
        end AS lesson_type,
        mst.del_flg AS del_flg,
        lsn.create_date AS create_date,
        lsn.update_date AS update_date
    FROM
        ((t_info_lesson lsn
        INNER JOIN t_mst_student mst ON ((lsn.stu_id = mst.stu_id)))
        INNER JOIN v_info_subject_edaban eda ON (((lsn.subject_id = eda.subject_id)
            AND (lsn.subject_sub_id = eda.subject_sub_id))))
;

USE prod_KNStudent;
-- 前提条件，加课换正课执行完了，换正课的lesson_id会将t_info_lesson_fee表中的该记录的del_flg更新为0
-- 同时，会在t_info_lesson_extra_to_sche中记录原来的lsn_fee_id和换正课后所在月份的新的lsn_fee_id
-- 该视图就是将原来的课费信息和换正课后的课费信息进行了重新整合。
-- DROP VIEW IF EXISTS v_info_lesson_fee_include_extra2sche;
CREATE VIEW v_info_lesson_fee_include_extra2sche AS 
select 
	lsn_fee_id,
    lesson_id,
    pay_style,
    lsn_fee,
    lsn_month,
    own_flg,
    0 as del_flg,
    0 as extra2sche_flg, -- 正常课程标识
    create_date,
    update_date
from t_info_lesson_fee 
where del_flg = 0
union all
select 
	ext.new_lsn_fee_id as lsn_fee_id,
    fee.lesson_id,
    fee.pay_style,
    fee.lsn_fee,
    substring(ext.new_scanqr_date,1,7) as lsn_month,
    ext.new_own_flg as own_flg,
    0 as del_flg,
    1 as extra2sche_flg, -- 加课换正课标识
    fee.create_date,
    fee.update_date
from 
t_info_lesson_fee fee
inner join
t_info_lesson_extra_to_sche ext
on fee.lesson_id = ext.lesson_id
and fee.del_flg = 1
;


-- 21授業料金情報管理
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson_fee_connect_lsn`;
-- 视图 从t_info_lesson_fee表里抽出学生各自科目的费用信息
-- 这里的课程都是已经签到完了的课程记录
-- 月计划的情况下（lesson_type=1),4个lesson_id对应1个lsn_fee_id
-- 月加课和课结算的情况下（lesson_type=0，1),1个lesson_id对应1个lsn_fee_id
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_info_lesson_fee_connect_lsn AS
    SELECT 
        fee.lsn_fee_id AS lsn_fee_id,
        fee.lesson_id AS lesson_id,
        lsn.lesson_type AS lesson_type,
        (lsn.class_duration / doc.minutes_per_lsn) AS lsn_count,
        doc.stu_id AS stu_id,
        case when doc.del_flg = 1 then  CONCAT(doc.stu_name, '(已退学)')
             else doc.stu_name
        end AS stu_name,
        doc.subject_id AS subject_id,
        doc.subject_name AS subject_name,
        doc.pay_style AS pay_style,
        lsn.subject_sub_id AS subject_sub_id,
        doc.subject_sub_name AS subject_sub_name,
        (CASE
            WHEN (doc.lesson_fee_adjusted > 0) THEN doc.lesson_fee_adjusted
            ELSE doc.lesson_fee
        END) AS subject_price,
        (fee.lsn_fee * (lsn.class_duration / doc.minutes_per_lsn)) AS lsn_fee,
        fee.lsn_month AS lsn_month,
        fee.own_flg AS own_flg,
        fee.del_flg AS del_flg,
        fee.extra2sche_flg,
        fee.create_date AS create_date,
        fee.update_date AS update_date
    FROM
        ((v_info_lesson_fee_include_extra2sche fee
        JOIN v_info_lesson_include_extra2sche lsn ON (((fee.lesson_id = lsn.lesson_id)
            AND (fee.del_flg = 0)
            AND (lsn.del_flg = 0))))
        LEFT JOIN v_info_student_document doc ON (((lsn.stu_id = doc.stu_id)
            AND (lsn.subject_id = doc.subject_id)
            AND (lsn.subject_sub_id = doc.subject_sub_id)
            AND (doc.adjusted_date = (SELECT 
                MAX(studoc.adjusted_date)
            FROM
                v_info_student_document studoc
            WHERE
                ((studoc.stu_id = doc.stu_id)
                    AND (studoc.subject_id = doc.subject_id)
                    AND (studoc.subject_sub_id = doc.subject_sub_id)
                    AND (DATE_FORMAT(studoc.adjusted_date, '%Y/%m/%d') <= DATE_FORMAT(lsn.schedual_date, '%Y/%m/%d'))))))))
    ORDER BY fee.lsn_month;

-- 📱手机端用视图 课程进度统计，用该视图取出的数据初期化手机页面的graph图
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lsn_statistics_by_stuid`;
CREATE
 	ALGORITHM=UNDEFINED 
	DEFINER=`root`@`localhost` 
	SQL SECURITY DEFINER 
VIEW `v_info_lsn_statistics_by_stuid`
AS 
SELECT 
	stu_id 
   ,stu_name
   ,subject_name
   ,subject_id
   ,subject_sub_id
   ,subject_sub_name
   ,lesson_type
   ,sum(lsn_count) as lsn_count
   ,lsn_month
FROM v_info_lesson_fee_connect_lsn 
GROUP BY
   stu_id
   ,stu_name
   ,subject_name
   ,subject_id
   ,subject_sub_id
   ,subject_sub_name
   ,lesson_type
   ,lsn_month
ORDER BY lsn_month,subject_id,subject_sub_id;


USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson_sum_fee_unpaid_yet`;
-- 📱视图 从v_info_lesson_fee_connect_lsn表里每个每月上完每个科目的课数和未支付课费做统计
-- 手机前端页面使用
/* 该视图被下列视图给调用了
		v_sum_unpaid_lsnfee_by_stu_and_month
 */
CREATE 
	ALGORITHM=UNDEFINED 
	DEFINER=`root`@`localhost` 
	SQL SECURITY DEFINER 
VIEW `v_info_lesson_sum_fee_unpaid_yet` 
AS 
/* 
把按月交费的科目做一个统计，月交费场合下的lsn_fee_id lesson_id是1:n的关系，
此视图是将n个lesson的课时和课费做一个求和统计，
使得lsn_pay_id,lsn_fee_id能清楚地表达出这两个字段的1:1关系
*/
SELECT
    '' as lsn_pay_id,
    newtmptbl.lsn_fee_id,    -- 明确指定来源
    newtmptbl.stu_id,
    newtmptbl.stu_name,
    newtmptbl.subject_id,
    newtmptbl.subject_name,
    newtmptbl.subject_sub_id,
    newtmptbl.subject_sub_name,
    newtmptbl.subject_price,
    newtmptbl.pay_style,
    SUM(newtmptbl.lsn_count) AS lsn_count,
    sum(case when newtmptbl.lesson_type = 1 then newtmptbl.subject_price * 4
           else newtmptbl.lsn_fee end ) as lsn_fee,
    NULL as pay_date,
    newtmptbl.lesson_type,
    newtmptbl.lsn_month,
    newtmptbl.own_flg 
from (
    SELECT 
        lsn_fee_id,
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
        subject_price,
        pay_style,
        SUM(lsn_count) AS lsn_count,
        SUM(lsn_fee) as lsn_fee,
        lesson_type,
        lsn_month,
        own_flg 
    FROM 
        v_info_lesson_fee_connect_lsn
    WHERE 
        own_flg = 0
        AND del_flg = 0
    GROUP BY 
        lsn_fee_id,
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
        subject_price,
        pay_style,
        lesson_type,
        lsn_month,
        own_flg
) newtmptbl
GROUP BY 
    newtmptbl.lsn_fee_id,
    newtmptbl.stu_id,
    newtmptbl.stu_name,
    newtmptbl.subject_id,
    newtmptbl.subject_name,
    newtmptbl.subject_sub_id,
    newtmptbl.subject_sub_name,
    newtmptbl.subject_price,
    newtmptbl.pay_style,
    newtmptbl.lesson_type,
    newtmptbl.lsn_month,
    newtmptbl.own_flg;


USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson_sum_fee_pay_over`;
-- 📱视图 从v_info_lesson_fee_connect_lsn表里每月上完的课数和已支付课费做统计
-- 手机前端页面使用
/* 该视图也被下列视图调用：
		v_info_lesson_pay_over、
		v_sum_haspaid_lsnfee_by_stu_and_month */ 
CREATE 
	ALGORITHM=UNDEFINED 
	DEFINER=`root`@`localhost` 
	SQL SECURITY DEFINER 
VIEW `v_info_lesson_sum_fee_pay_over` 
AS 
/* 
把按月交费的科目做一个统计，月交费场合下的lsn_fee_id lesson_id是1:n的关系，
此视图是将n个lesson的课时和课费做一个求和统计，
使得lsn_pay_id,lsn_fee_id能清楚地表达出这两个字段的1:1关系
*/
SELECT 
	pay.lsn_pay_id,
    fee.lsn_fee_id,
    fee.stu_id,
    fee.stu_name,
    fee.subject_id,
    fee.subject_name,
    fee.subject_sub_id,
    fee.subject_sub_name,
    fee.subject_price,
    fee.pay_style,
    SUM(fee.lsn_count) AS lsn_count,
    SUM(pay.lsn_pay) AS lsn_fee,
    pay.pay_date,
    pay.bank_id,
    fee.lsn_month,
    fee.lesson_type
FROM 
    (SELECT
			  lsn_fee_id,
				stu_id,
				stu_name,
				subject_id,
				subject_name,
				subject_sub_id,
				subject_sub_name,
			    subject_price,
				pay_style,
			    lesson_type,
				SUM(CASE 
					WHEN lesson_type = 1 THEN subject_price * 4
					ELSE lsn_fee
				END) AS lsn_fee,
			    lsn_count,
				lsn_month
			FROM(
				SELECT 
					lsn_fee_id,
					stu_id,
					stu_name,
					subject_id,
			        subject_name,
			        subject_sub_id,
			        subject_sub_name,
					subject_price,
			        pay_style,
					lesson_type,
			        sum(lsn_count) as lsn_count,
					sum(lsn_fee) as lsn_fee,
					lsn_month
				FROM v_info_lesson_fee_connect_lsn
			    where own_flg = 1
				GROUP BY lsn_fee_id,stu_id,stu_name,		
			    subject_id,
			        subject_name,
			        subject_sub_id,
			        subject_sub_name,lsn_month,subject_price,pay_style,lesson_type
			    )aa
			GROUP BY lsn_fee_id,stu_id,stu_name,		
			    subject_id,
			        subject_name,
			        subject_sub_id,
			        subject_sub_name,lsn_month,subject_price,pay_style,lesson_type,lsn_count
    ) fee
    inner join
    t_info_lesson_pay pay
On
	fee.lsn_fee_id = pay.lsn_fee_id
GROUP BY 
	pay.lsn_pay_id,
    fee.lsn_fee_id,
    fee.stu_id,
    fee.stu_name,
    fee.subject_id,
    fee.subject_name,
    fee.subject_sub_id,
    fee.subject_sub_name,
    fee.subject_price,
    fee.pay_style,
    fee.lsn_month,
    pay.pay_date,
    fee.lesson_type;


-- 22授業課費精算管理
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson_pay_over`;
-- 视图 从t_info_lesson_pay表里抽取精算完了的学生课程信息
-- 后台维护用
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_lesson_pay_over` AS
    SELECT 
        `vsumfee`.`lsn_pay_id` AS `lsn_pay_id`,
        `vsumfee`.`lsn_fee_id` AS `lsn_fee_id`,
        `vsumfee`.`stu_id` AS `stu_id`,
        `vsumfee`.`stu_name` AS `stu_name`,
        `vsumfee`.`subject_id` AS `subject_id`,
        `vsumfee`.`subject_name` AS `subject_name`,
        `vsumfee`.`subject_sub_id` AS `subject_sub_id`,
        `vsumfee`.`subject_sub_name` AS `subject_sub_name`,
        `vsumfee`.`pay_style` AS `pay_style`,
        `vsumfee`.`lesson_type` AS `lesson_type`,
        `vsumfee`.`lsn_count` AS `lsn_count`,
        `vsumfee`.`lsn_fee` AS `lsn_fee`,
        `bnk`.`bank_id` AS `bank_id`,
        `bnk`.`bank_name` AS `bank_name`,
        `vsumfee`.`lsn_month` AS `pay_month`,
        `vsumfee`.`pay_date` AS `pay_date`
    FROM
          `v_info_lesson_sum_fee_pay_over` `vsumfee` 
        left JOIN `t_mst_bank` `bnk` ON (`vsumfee`.`bank_id` = `bnk`.`bank_id`)
;


-- 23学费月度报告的分组查询 
-- ①未支付学费统计（分组查询学生，月份）
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_sum_unpaid_lsnfee_by_stu_and_month`;
-- 后台维护用
-- 本视图被下列视图单独调用
   -- v_total_lsnfee_with_paid_unpaid_every_month
   -- v_total_lsnfee_with_paid_unpaid_every_month_every_student
-- ①每个学生每个月未支付状况的分组合计 v_sum_unpaid_lsnfee_by_stu_and_month
create view v_sum_unpaid_lsnfee_by_stu_and_month as
select stu_id
	    ,stu_name
      ,SUM(lsn_fee) AS lsn_fee
      ,lsn_month
from v_info_lesson_sum_fee_unpaid_yet
group by stu_id
		 ,stu_name
     ,lsn_month
;

-- ②未支付学费统计（分组查询月份Only）
-- ③已支付学费统计（分组查询学生，月份）
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_sum_haspaid_lsnfee_by_stu_and_month`;

-- 后台维护用
-- 本视图被下列视图单独调用
   -- v_total_lsnfee_with_paid_unpaid_every_month
   -- v_total_lsnfee_with_paid_unpaid_every_month_every_student
-- ③所有在课学生的每个月已支付状况的分组合计 v_sum_haspaid_lsnfee_by_stu_and_month
create view v_sum_haspaid_lsnfee_by_stu_and_month as
select stu_id
	    ,stu_name
      ,SUM(lsn_fee) AS lsn_fee
      ,lsn_month
from v_info_lesson_sum_fee_pay_over
group by stu_id
		  ,stu_name
      ,lsn_month
;

-- ④对课费管理视图的学费（已支付未支付都包括在内）的总计算按学生按月的分组查询
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`;

-- 后台维护用
-- 本视图被下列视图单独调用
	-- v_total_lsnfee_with_paid_unpaid_every_month 
	-- v_total_lsnfee_with_paid_unpaid_every_month_every_student
-- ④对课费管理视图的学费（已支付未支付都包括在内）的总计算按学生按月的分组查询 v_sum_lsn_fee_for_fee_connect_lsn
create view v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month AS
SELECT
    lsn_fee_id,
	stu_id,
	stu_name,
	subject_id,
	subject_name,
	subject_sub_id,
	subject_sub_name,
    subject_price,
	pay_style,
    lesson_type,
	SUM(CASE 
		WHEN lesson_type = 1 THEN subject_price * 4
		ELSE lsn_fee
	END) AS lsn_fee,
    lsn_count,
	lsn_month
FROM(
	SELECT 
		lsn_fee_id,
		stu_id,
		stu_name,
		subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
		subject_price,
        pay_style,
		lesson_type,
        sum(lsn_count) as lsn_count,
		sum(lsn_fee) as lsn_fee,
		lsn_month
	FROM v_info_lesson_fee_connect_lsn
	GROUP BY lsn_fee_id,stu_id,stu_name,		
    subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,lsn_month,subject_price,pay_style,lesson_type
    )aa
GROUP BY lsn_fee_id,stu_id,stu_name,		
    subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,lsn_month,subject_price,pay_style,lesson_type,lsn_count
;

-- (学生总综合)所有学生当前年度每月总课费的总支付，未支付状况查询
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_total_lsnfee_with_paid_unpaid_every_month`;
-- 后台维护用
-- 所有在课学生的每个月总课费，已支付，未支付状况 v_total_lsnfee_with_paid_unpaid_every_month
create view v_total_lsnfee_with_paid_unpaid_every_month as
SELECT 
    SUM(should_pay_lsn_fee) AS should_pay_lsn_fee,
    SUM(has_paid_lsn_fee) AS has_paid_lsn_fee,
    SUM(unpaid_lsn_fee) AS unpaid_lsn_fee,
    lsn_month
FROM (
		-- 使用④，每月总课费合计
		SELECT 
			SUM(lsn_fee) AS should_pay_lsn_fee,
			0.0 AS has_paid_lsn_fee,
			0.0 AS unpaid_lsn_fee,
		    lsn_month
		From v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month
		group by lsn_month
    UNION ALL
    -- 使用③，每已支付课费合计
    SELECT 
        0.0 AS should_pay_lsn_fee,
        SUM(lsn_fee) AS has_paid_lsn_fee,
        0.0 AS unpaid_lsn_fee,
        lsn_month
    FROM v_sum_haspaid_lsnfee_by_stu_and_month
    GROUP BY lsn_month
    UNION ALL
    -- 使用①，每月未支付课费合计
    SELECT 
        0.0 AS should_pay_lsn_fee,
        0.0 AS has_paid_lsn_fee,
        SUM(lsn_fee) AS unpaid_lsn_fee,
        lsn_month
    FROM v_sum_unpaid_lsnfee_by_stu_and_month
    GROUP BY lsn_month
) AS lsn_fee_alias -- 别名用于整个派生表的引用
GROUP BY lsn_month;

-- （学生明细综合）每个学生当前年度每月总课费的总支付，未支付状况查询
USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_total_lsnfee_with_paid_unpaid_every_month_every_student`;
-- 后台维护用
-- 每个学生当前年度每月总课费的总支付，未支付状况查询 v_total_lsnfee_with_paid_unpaid_every_month_every_student
create view v_total_lsnfee_with_paid_unpaid_every_month_every_student as
select stu_id
	  ,stu_name
	  ,sum(should_pay_lsn_fee) as should_pay_lsn_fee
      ,sum(has_paid_lsn_fee) as has_paid_lsn_fee
      ,sum(unpaid_lsn_fee) as unpaid_lsn_fee
      ,lsn_month
from (
	SELECT 
		stu_id,
		stu_name,
		SUM(lsn_fee) AS should_pay_lsn_fee,
		0.0 AS has_paid_lsn_fee,
		0.0 AS unpaid_lsn_fee,
		lsn_month
	From v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month
	group by stu_id, stu_name,lsn_month
	union all
	select 
		stu_id,
		stu_name,
		0.0 as should_pay_lsn_fee,
		sum(lsn_fee) as has_paid_lsn_fee,
		0.0 as unpaid_lsn_fee,
		lsn_month
	from v_sum_haspaid_lsnfee_by_stu_and_month
	group by stu_id,stu_name,lsn_month
	union all
	select 
		stu_id,
		stu_name,
		0.0 as should_pay_lsn_fee,  
		0.0 as has_paid_lsn_fee,
		sum(lsn_fee) as unpaid_lsn_fee,
		lsn_month
	from v_sum_unpaid_lsnfee_by_stu_and_month
	group by stu_id,stu_name,lsn_month
) lsn_fee_status_by_stu_and_month
group by stu_id, stu_name, lsn_month;

uSE prod_KNStudent;
-- DROP VIEW IF EXISTS v_info_all_extra_lsns;
-- 前提条件，加课都已经签到完了，找出那些已经结算和还未结算的加课信息
-- 已经结算的加课费
CREATE VIEW v_info_all_extra_lsns AS 
SELECT 
	-- pay.lsn_pay_id, 
    -- fee.lsn_fee_id, 
    lsn.lesson_id,
    lsn.stu_id,
    lsn.subject_id,
    lsn.subject_sub_id,
    lsn.class_duration,
    lsn.lesson_type,
    lsn.schedual_type,
    lsn.schedual_date,
    lsn.lsn_adjusted_date,
    lsn.extra_to_dur_date,
    lsn.scanqr_date,
    1 as pay_flg 
FROM 
	t_info_lesson lsn
	inner join 
	t_info_lesson_fee fee
	on lsn.lesson_id = fee.lesson_id and fee.del_flg = 0
	inner join
	t_info_lesson_pay pay
	on fee.lsn_fee_id = pay.lsn_fee_id
	where lsn.scanqr_date is not null 
	and lsn.lesson_type = 2 -- 2是加课课程的标识数字
union all
-- 已经结算的加课费
SELECT 
    main.lesson_id,
    main.stu_id,
    main.subject_id,
    main.subject_sub_id,
    main.class_duration,
    main.lesson_type,
    main.schedual_type,
    main.schedual_date,
    main.lsn_adjusted_date,
    main.extra_to_dur_date,
    main.scanqr_date,
    0 as pay_flg 
FROM t_info_lesson main
WHERE main.scanqr_date IS NOT NULL 
  AND main.lesson_type = 2
  AND NOT EXISTS (
    SELECT 1 
    FROM t_info_lesson lsn
    INNER JOIN t_info_lesson_fee fee ON lsn.lesson_id = fee.lesson_id
    INNER JOIN t_info_lesson_pay pay ON fee.lsn_fee_id = pay.lsn_fee_id
    WHERE lsn.lesson_id = main.lesson_id
  );

-- ///// FUNCTION ///////////////////////////////////////////////////////////////////////////////
USE prod_KNStudent;
-- DROP FUNCTION IF EXISTS `currval`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `currval`(seq_id VARCHAR(50))
RETURNS int
DETERMINISTIC
BEGIN
    DECLARE value INTEGER;
    SET value = 0;
    SELECT current_value INTO value
        FROM sequence
        WHERE seqid = seq_id;
    RETURN value;
END//
DELIMITER ;

USE prod_KNStudent;
-- DROP FUNCTION IF EXISTS `nextval`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `nextval`(seq_id VARCHAR(50)) RETURNS int
    DETERMINISTIC
BEGIN
    UPDATE sequence
    SET current_value = current_value + increment
    WHERE seqid = seq_id;
    RETURN currval(seq_id);
END//
DELIMITER ;

USE prod_KNStudent;
-- DROP FUNCTION IF EXISTS `setval`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `setval`(seq_id VARCHAR(50), value INTEGER) RETURNS int
    DETERMINISTIC
BEGIN
    UPDATE sequence
    SET current_value = value
    WHERE seqid = seq_id;
    RETURN currval(seq_id);
END//
DELIMITER ;


-- ///// TRIGGER ///////////////////////////////////////////////////////////////////////////////
-- 01学生基本情報マスタ：创建更新日触发器
USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_mst_student`;
-- 更新t_mst_student表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_mst_student
BEFORE UPDATE ON t_mst_student
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;

-- 02学科基本情報マスタ：创建更新日触发器
USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_mst_subject`;
-- 更新t_mst_subject表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_mst_subject
BEFORE UPDATE ON t_mst_subject
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;


USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_info_subject_edaban`;
-- 更新t_info_subject_edaban表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_info_subject_edaban
BEFORE UPDATE ON t_info_subject_edaban
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;


-- 03銀行基本情報マスタ：创建更新日触发器
USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_mst_bank`;
-- 更新t_mst_bank表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_mst_bank
BEFORE UPDATE ON t_mst_bank
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;


USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_info_student_bank`;
-- 更新t_info_student_bank表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_info_student_bank
BEFORE UPDATE ON t_info_student_bank
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;


-- 11学生歴史ドキュメント情報：创建更新日触发器
USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_info_student_document`;
-- 更新t_info_student_document表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_info_student_document
BEFORE UPDATE ON t_info_student_document
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;


-- 12学生授業情報管理：创建更新日触发器
USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_info_lesson`;
-- 更新t_info_lesson表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_info_lesson
BEFORE UPDATE ON t_info_lesson
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;

-- 21授業料金情報管理：创建更新日触发器
USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_info_lesson_fee`;
-- 更新t_info_lesson_fee表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_info_lesson_fee
BEFORE UPDATE ON t_info_lesson_fee
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;


-- 22授業課費精算管理
USE prod_KNStudent;
-- DROP TRIGGER IF EXISTS `before_update_t_info_lesson_pay`;
-- 更新t_info_lesson_pay表update_date字段的触发器
DELIMITER $$
CREATE TRIGGER before_update_t_info_lesson_pay
BEFORE UPDATE ON t_info_lesson_pay
FOR EACH ROW
BEGIN
   SET NEW.update_date = CURRENT_TIMESTAMP;
END$$
DELIMITER ;


-- ///// PROCEDURE ///////////////////////////////////////////////////////////////////////////////
-- 1.年利用度星期生成表结合学生固定排课表，对学生进行一星期自动化排课
USE prod_KNStudent;
-- DROP FUNCTION IF EXISTS `generate_weekly_date_series`;
-- 保持日期序列生成函数不变只要一周的表数据信息
DELIMITER //
CREATE FUNCTION generate_weekly_date_series(start_date_str VARCHAR(10), end_date_str VARCHAR(10))
RETURNS VARCHAR(4000)
DETERMINISTIC
BEGIN
    DECLARE date_list VARCHAR(4000);
    DECLARE curr_date DATE;
    DECLARE start_date DATE;
    DECLARE end_date DATE;
    
    SET start_date = STR_TO_DATE(start_date_str, '%Y-%m-%d');
    SET end_date = STR_TO_DATE(end_date_str, '%Y-%m-%d');
    
    SET date_list = '';
    SET curr_date = start_date;
    
    WHILE curr_date <= end_date DO
        SET date_list = CONCAT(date_list, DATE_FORMAT(curr_date, '%Y-%m-%d'), ',');
        SET curr_date = DATE_ADD(curr_date, INTERVAL 1 DAY);
    END WHILE;
    
    RETURN TRIM(TRAILING ',' FROM date_list);
END //
DELIMITER ;

-- 创建一个存储过程来生成日期范围
USE prod_KNStudent;
-- DROP PROCEDURE IF EXISTS `sp_weekly_batch_lsn_schedule_process`;
/**
INPUT：一周的开始日期和一周的结束日期
OUTPUT：生成要插入到上课信息表的一周的结果集
*/
DELIMITER //
CREATE PROCEDURE sp_weekly_batch_lsn_schedule_process(IN start_date_str VARCHAR(10), IN end_date_str VARCHAR(10), IN SEQCode VARCHAR(20))
BEGIN
    -- 创建临时表
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_date_range (
        date_column DATE,
        weekday_column VARCHAR(20)
    );

    -- 清空临时表
    TRUNCATE TABLE temp_date_range;

    -- 插入数据
    INSERT INTO temp_date_range (date_column, weekday_column)
    SELECT 
        STR_TO_DATE(date_column, '%Y-%m-%d') AS date_column,
        DATE_FORMAT(STR_TO_DATE(date_column, '%Y-%m-%d'), '%a') AS weekday_column
    FROM (
        SELECT DISTINCT
            SUBSTRING_INDEX(SUBSTRING_INDEX(generate_weekly_date_series(start_date_str, end_date_str), ',', numbers.n), ',', -1) AS date_column
        FROM (
            SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
            UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
            UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
            UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14
        ) numbers
    ) date_range;

    -- 显示结果
    -- SELECT * FROM temp_date_range;
    -- 根据关联表，将制定日期范围的学生排课信息直接插入到上课信息表【t_info_lesson】的数据
	INSERT INTO t_info_lesson (lesson_id,subject_id,subject_sub_id,stu_id,class_duration,lesson_type,schedual_type,schedual_date)
    SELECT 
		CONCAT(SEQCode, nextval(SEQCode)) as lesson_id,
        fix.subject_id,
        doc.subject_sub_id,
		fix.stu_id,
		doc.minutes_per_lsn as class_duration,
		CASE 
			WHEN doc.pay_style = 0 THEN 0
			WHEN doc.pay_style = 1 THEN 1
		END AS lesson_type,
        1 AS schedual_type,
		CONCAT(cdr.date_column, ' ', LPAD(fix.fixed_hour, 2, '0'), ':', LPAD(fix.fixed_minute, 2, '0')) as schedual_date
	FROM 
		t_info_fixedlesson fix -- 一周排课的日期范围
	LEFT JOIN 
		v_latest_subject_info_from_student_document doc -- 学生档案最新正在上课的科目信息
		ON fix.stu_id = doc.stu_id AND fix.subject_id = doc.subject_id
	INNER JOIN 
		temp_date_range cdr
		ON cdr.weekday_column = fix.fixed_week; -- 学生固定排课表
END //
DELIMITER ;
-- 使用示例
-- CALL create_date_range('2024-08-12', '2024-08-18');


-- 2.在课学生课程费用按照学生和月的分组合计
USE prod_KNStudent;
-- DROP PROCEDURE IF EXISTS `sp_sum_unpaid_lsnfee_by_stu_and_month`;
DELIMITER //
-- 每个学生每个月未支付状况的分组合计 sp_sum_unpaid_lsnfee_by_stu_and_month
CREATE PROCEDURE sp_sum_unpaid_lsnfee_by_stu_and_month (IN currentYear VARCHAR(4))
BEGIN
    SET @sql = CONCAT('
        SELECT 
            stu_id,
            stu_name,
            SUM(CASE 
                    WHEN lesson_type = 1 THEN subject_price * 4
                    ELSE lsn_fee
                END) AS lsn_fee,
            lsn_month
        FROM v_info_lesson_sum_fee_unpaid_yet
        WHERE SUBSTRING(lsn_month, 1, 4) = ', currentYear, '
        GROUP BY stu_id, stu_name, lsn_month
        ORDER BY lsn_month, CAST(SUBSTRING_INDEX(stu_id, ''-'', -1) AS UNSIGNED);
    ');

    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- 推算预支付课程的排课日期
USE prod_KNStudent;
DELIMITER //
-- DROP PROCEDURE IF EXISTS sp_get_advance_pay_subjects_and_lsnschedual_info //
CREATE DEFINER=`root`@`%` PROCEDURE `sp_get_advance_pay_subjects_and_lsnschedual_info`(IN p_stuId VARCHAR(32), IN p_yearMonth VARCHAR(7))
BEGIN
    DECLARE v_first_day DATE;
    -- 临时禁用安全更新模式，以允许不使用主键的更新操作
    SET SQL_SAFE_UPDATES = 0;
    
    -- 确保临时表不存在，防止重复创建错误
    DROP TEMPORARY TABLE IF EXISTS temp_result;

    -- 创建临时表来存储计算后的结果
    CREATE TEMPORARY TABLE temp_result AS
	-- 第一部分：获取学生档案中存在但在课程信息表中不存在的科目数据
	WITH MaxSubIds AS (
	 -- 取得学生们各科目中截止到目前学过的或正在学的最大子科目（即，子科目id值最大的那个科目） 
		SELECT 
			t.*
		FROM v_latest_subject_info_from_student_document t
		INNER JOIN (
			SELECT 
				stu_id,
				subject_id,
				MAX(CAST(SUBSTRING_INDEX(subject_sub_id, '-', -1) AS UNSIGNED)) as max_num
			FROM v_latest_subject_info_from_student_document
			WHERE 1 = 1
            AND pay_style = 1 -- 仅限于按月交费的科目
			-- 价格调整日期小于系统当前日期，目的是防止未来准备要上，目前还没有开始上的科目不出现在当前的预支付中
			AND adjusted_date <= CURDATE()
			GROUP BY stu_id, subject_id
		) m ON t.stu_id = m.stu_id 
			AND t.subject_id = m.subject_id
			-- 学科子科目（例如：钢琴1级，2级等）的最大值
			AND CAST(SUBSTRING_INDEX(t.subject_sub_id, '-', -1) AS UNSIGNED) = m.max_num
			-- 只限于当前在课的学生
			AND t.stu_id in (select stu_id from t_mst_student where del_flg = 0)
	)
	(SELECT 
		doc.stu_id,
		doc.stu_name,
		doc.subject_id,
		doc.subject_name,
		doc.subject_sub_id,
		doc.subject_sub_name,
		CASE 
			WHEN doc.pay_style = 1 THEN 1
		END as lesson_type,
		NULL AS schedual_date
	FROM (
		SELECT 
			stu_id,
			stu_name,
			subject_id,
			subject_name,
			subject_sub_id,
			subject_sub_name,
			lesson_type,
			MAX(schedual_date) AS schedual_date
		FROM v_info_lesson
		WHERE scanQR_date IS NOT NULL and lesson_type = 1
		GROUP BY 
			stu_id,
			stu_name,
			subject_id,
			subject_name,
			subject_sub_id,
			lesson_type,
			subject_sub_name
	) lsn
	RIGHT JOIN MaxSubIds doc
	ON lsn.stu_id = doc.stu_id 
	AND lsn.subject_id = doc.subject_id
	AND lsn.subject_sub_id = doc.subject_sub_id
	WHERE lsn.stu_id IS NULL
	  AND doc.stu_id = p_stuId
      -- 价格调整日期小于系统当前日期，目的是防止未来准备要上，目前还没有开始上的科目不出现在当前的预支付中
	  AND doc.adjusted_date <= CURDATE()
	  AND LEFT(lsn.schedual_date,4) = LEFT(CURDATE(),4))
	UNION ALL
	-- 第二部分：获取学生在课程信息表中的现有课程数据
	SELECT 
		t1.stu_id,
		t1.stu_name,
		t1.subject_id,
		t1.subject_name,
		t1.subject_sub_id,
		t1.subject_sub_name,
		t1.lesson_type,
		t1.schedual_date
	FROM (
		SELECT 
			v.*,
			MAX(schedual_date) OVER (PARTITION BY stu_id, subject_id) as max_date
		FROM v_info_lesson v
		WHERE v.stu_id = p_stuId
		  AND v.scanQR_date IS NOT NULL 
		  AND v.lesson_type = 1
          -- 排课日期只参考去年到现在的排课日期
          AND LEFT(v.schedual_date,4) >= LEFT(CURDATE(),4) - 1
	) t1
	INNER JOIN (
		SELECT 
			stu_id,
			subject_id,
			MAX(CAST(SUBSTRING_INDEX(subject_sub_id, '-', -1) AS UNSIGNED)) as max_num
		FROM v_info_lesson
		WHERE stu_id = p_stuId
		  AND scanQR_date IS NOT NULL 
		  AND lesson_type = 1
		GROUP BY stu_id, subject_id
	) t2 ON t1.stu_id = t2.stu_id 
		AND t1.subject_id = t2.subject_id
		AND CAST(SUBSTRING_INDEX(t1.subject_sub_id, '-', -1) AS UNSIGNED) = t2.max_num
	WHERE t1.schedual_date = t1.max_date;

	-- 创建临时表来存储统计p_yearMonth月里里签到的课程数量
    DROP TEMPORARY TABLE IF EXISTS temp_scaned_count;
	CREATE TEMPORARY TABLE IF NOT EXISTS temp_scaned_count AS
	SELECT subject_id, COUNT(subject_sub_id) as subject_sub_id_count 
	FROM t_info_lesson
	WHERE stu_id = p_stuId
		AND LEFT(schedual_date,7) = p_yearMonth
		AND scanqr_date IS NOT NULL
	GROUP BY subject_id;

	-- 根据签到的统计结果进行判断：如果subject_sub_id_count大于0，预支付的对象月是下一个月，没有签到记录，就是当前月
	IF EXISTS (SELECT 1 FROM temp_scaned_count WHERE subject_sub_id_count > 0) THEN
		-- 如果有签到记录，取下个月的第一天
		SET v_first_day = DATE(DATE_FORMAT(DATE_ADD(CONCAT(p_yearMonth, '-01'), INTERVAL 1 MONTH), '%Y-%m-01'));
	ELSE
		-- 如果没有签到记录，取当前传入月份的第一天
		SET v_first_day = DATE(CONCAT(p_yearMonth, '-01'));
	END IF;
	
    
    -- 更新临时表中的排课计划日期(因为临时表存放的是过去最新的排课参考用的信息，现在要把它的排课日期更新成要预支付的排课日期)
    UPDATE temp_result tr
    LEFT JOIN v_earliest_fixed_week_info AS vefw
    ON tr.stu_id = vefw.stu_id AND tr.subject_id = vefw.subject_id
    SET tr.schedual_date = 
        CASE 
            WHEN vefw.stu_id IS NOT NULL THEN
                -- 复杂的日期计算逻辑，用于确定给定月份中每个课程的第一个上课日期
                DATE_FORMAT(
                    DATE_ADD(
                        v_first_day,
                        INTERVAL (
                            CASE 
                                WHEN DAYOFWEEK(v_first_day) > CASE vefw.fixed_week
                                                                WHEN 'Mon' THEN 2
                                                                WHEN 'Tue' THEN 3
                                                                WHEN 'Wed' THEN 4
                                                                WHEN 'Thu' THEN 5
                                                                WHEN 'Fri' THEN 6
                                                                WHEN 'Sat' THEN 7
                                                                WHEN 'Sun' THEN 1
                                                              END
                                THEN 7 + CASE vefw.fixed_week
                                            WHEN 'Mon' THEN 0
                                            WHEN 'Tue' THEN 1
                                            WHEN 'Wed' THEN 2
                                            WHEN 'Thu' THEN 3
                                            WHEN 'Fri' THEN 4
                                            WHEN 'Sat' THEN 5
                                            WHEN 'Sun' THEN 6
                                          END - DAYOFWEEK(v_first_day) + 2
                                ELSE CASE vefw.fixed_week
                                        WHEN 'Mon' THEN 0
                                        WHEN 'Tue' THEN 1
                                        WHEN 'Wed' THEN 2
                                        WHEN 'Thu' THEN 3
                                        WHEN 'Fri' THEN 4
                                        WHEN 'Sat' THEN 5
                                        WHEN 'Sun' THEN 6
                                     END - DAYOFWEEK(v_first_day) + 2
                            END
                        ) DAY
                    ),
                    CONCAT('%Y-%m-%d ', LPAD(vefw.fixed_hour, 2, '0'), ':', LPAD(vefw.fixed_minute, 2, '0'))
                )
            ELSE tr.schedual_date
        END
    WHERE tr.stu_id = p_stuId;

    -- 返回计算后结果:以该生目前最后一次的签到月份为基准，预支付该月以后月份的预支付课费
    -- 如果adv.schedual_date有值，表示该科目在固定排课表里有固定的排课记录
    -- 如果adv.schedual_date为空，表示该科目在固定排课表里还没有固定排课记录，仅此而已
   
    -- 把temp_result更新后的结果集再做JOIN关联，将新的结果存放到temp_result_updated临时表里
	DROP TEMPORARY TABLE IF EXISTS temp_result_updated;
	CREATE TEMPORARY TABLE temp_result_updated AS
	SELECT 
		adv.stu_id,
		adv.stu_name,
		adv.subject_id,
		adv.subject_name,
		adv.subject_sub_id,
		adv.subject_sub_name,
		adv.lesson_type,
		adv.schedual_date,
		vldoc.lesson_fee as subject_price,
		vldoc.minutes_per_lsn
	FROM temp_result adv
	INNER JOIN v_latest_subject_info_from_student_document vldoc
	ON adv.stu_id = vldoc.stu_id
	AND adv.subject_id = vldoc.subject_id
	AND adv.subject_sub_id = vldoc.subject_sub_id;
    
    -- 创建临时的学生档案表
    DROP TEMPORARY TABLE IF EXISTS temp_stu_doc;
    CREATE TEMPORARY TABLE temp_stu_doc AS
		SELECT 
		stu_id,
		stu_name,
		subject_id,
		subject_name,
		subject_sub_id,
		subject_sub_name,
		1 as lesson_type,
		null as schedual_date,
		lesson_fee as subject_price,
		minutes_per_lsn
	FROM v_latest_subject_info_from_student_document
	WHERE stu_id = p_stuId AND pay_style = 1;

    SET @count = (SELECT COUNT(*) FROM temp_result_updated);
	IF @count = 0 THEN
		SELECT * FROM temp_stu_doc;
	ELSE
		-- 存储第一个查询的结果到一个中间表（课程表里已有的科目）
		DROP TEMPORARY TABLE IF EXISTS temp_base_result;
		CREATE TEMPORARY TABLE temp_base_result AS
		SELECT * FROM temp_result_updated;
		
		-- 在同一个临时表中插入第二部分数据 （课程表里没有的科目）
		INSERT INTO temp_base_result
		SELECT * FROM temp_stu_doc 
		WHERE subject_id NOT IN (SELECT subject_id FROM temp_result_updated);
		
		-- 返回结果
		SELECT * FROM temp_base_result;
		
		-- 清理临时表
		DROP TEMPORARY TABLE IF EXISTS temp_base_result;
	END IF;

    -- 清理：删除临时表
	DROP TEMPORARY TABLE IF EXISTS temp_result_updated; 
    DROP TEMPORARY TABLE IF EXISTS temp_stu_doc;
	DROP TEMPORARY TABLE IF EXISTS temp_scaned_count;
	DROP TEMPORARY TABLE IF EXISTS temp_result;
    
    -- 重新启用安全更新模式
    SET SQL_SAFE_UPDATES = 1;
END //

DELIMITER ;


USE prod_KNStudent;
-- DROP PROCEDURE IF EXISTS `sp_execute_weekly_batch_lsn_schedule`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_execute_weekly_batch_lsn_schedule`(IN start_date_str VARCHAR(10), IN end_date_str VARCHAR(10), IN SEQCode VARCHAR(20))
BEGIN
    -- 声明常量
    DECLARE PROCEDURE_NAME VARCHAR(100) DEFAULT 'sp_execute_weekly_batch_lsn_schedule';
    DECLARE PROCEDURE_ALIAS_NAME VARCHAR(100) DEFAULT '执行周计划排课处理';

    -- 声明变量用于日志记录
    DECLARE v_step_result VARCHAR(255);
    DECLARE v_current_step VARCHAR(100) DEFAULT '初始化';
    DECLARE v_error_message TEXT;
    DECLARE v_affected_rows INT;

    -- 定义异常处理
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
        
        INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
        VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, 
                CONCAT('发生错误: ', v_error_message));
        
        -- 重新抛出错误
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_message;
    END;

    -- 创建临时表
    SET v_current_step = '创建临时表';
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_date_range (
        date_column DATE,
        weekday_column VARCHAR(20)
    );
    
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

    -- 清空临时表
    SET v_current_step = '清空临时表';
    TRUNCATE TABLE temp_date_range;
    
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

    -- 插入数据
    SET v_current_step = '生成日期和星期关系数据';
    INSERT INTO temp_date_range (date_column, weekday_column)
    SELECT 
        STR_TO_DATE(date_column, '%Y-%m-%d') AS date_column,
        DATE_FORMAT(STR_TO_DATE(date_column, '%Y-%m-%d'), '%a') AS weekday_column
    FROM (
        SELECT DISTINCT
            SUBSTRING_INDEX(SUBSTRING_INDEX(generate_weekly_date_series(start_date_str, end_date_str), ',', numbers.n), ',', -1) AS date_column
        FROM (
            SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
            UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
            UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
            UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14
        ) numbers
    ) date_range;

    SET v_affected_rows = ROW_COUNT();
    SET v_step_result = IF(v_affected_rows > 0, CONCAT('成功: 插入 ', v_affected_rows, ' 行'), '未插入任何行');
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    -- 创建临时表存储新的课程安排
    SET v_current_step = '创建临时表存储新的课程安排';
    -- 创建了一个临时表 temp_new_lessons 来存储所有可能的新课程安排。
    CREATE TEMPORARY TABLE temp_new_lessons AS
    SELECT 
        fix.subject_id,
        doc.subject_sub_id,
        fix.stu_id,
        doc.minutes_per_lsn as class_duration,
        CASE 
            WHEN doc.pay_style = 0 THEN 0
            WHEN doc.pay_style = 1 THEN 1
        END AS lesson_type,
        1 as schedual_type,
        CONCAT(cdr.date_column, ' ', LPAD(fix.fixed_hour, 2, '0'), ':', LPAD(fix.fixed_minute, 2, '0')) as schedual_date
    FROM 
        v_info_fixedlesson fix
    LEFT JOIN 
        v_latest_subject_info_from_student_document doc
        ON fix.stu_id = doc.stu_id AND fix.subject_id = doc.subject_id
	   -- AND fix.del_flg = 0 -- 已暂时停课的学生除外(目前该表无此字段)
    INNER JOIN 
        temp_date_range cdr
        ON cdr.weekday_column = fix.fixed_week;

    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

    -- 插入新的课程安排，排除已存在的课程 ：使用了 NOT EXISTS 子查询来确保只插入尚未存在的课程。
    SET v_current_step = '向t_info_lesson表插入新的课程安排';
    INSERT INTO t_info_lesson (lesson_id, subject_id, subject_sub_id, stu_id, class_duration, lesson_type, schedual_type, schedual_date)
    SELECT 
        CONCAT(SEQCode, nextval(SEQCode)) as lesson_id,
        tnl.subject_id,
        tnl.subject_sub_id,
        tnl.stu_id,
        tnl.class_duration,
        tnl.lesson_type,
        tnl.schedual_type,
        tnl.schedual_date
    FROM 
        temp_new_lessons tnl
    WHERE NOT EXISTS (
        SELECT 1
        FROM t_info_lesson til
        WHERE til.stu_id = tnl.stu_id
        AND til.subject_id = tnl.subject_id
        AND til.subject_sub_id = tnl.subject_sub_id
        AND til.schedual_date = tnl.schedual_date
        AND til.schedual_type = 1
    );

    SET v_affected_rows = ROW_COUNT();
    SET v_step_result = IF(v_affected_rows > 0, CONCAT('成功: 插入 ', v_affected_rows, ' 行'), '未插入任何行');
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    -- 删除临时表
    SET v_current_step = '删除临时表';
    DROP TEMPORARY TABLE IF EXISTS temp_date_range;
    DROP TEMPORARY TABLE IF EXISTS temp_new_lessons;
    
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

    -- 存储过程完成
    SET v_current_step = '存储过程完成';
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');
END //
DELIMITER ;


USE prod_KNStudent;
-- DROP PROCEDURE IF EXISTS `sp_execute_advc_lsn_fee_pay`;
DELIMITER //
CREATE PROCEDURE sp_execute_advc_lsn_fee_pay(
    IN p_stu_id VARCHAR(32),
    IN p_subject_id VARCHAR(32),
    IN p_subject_sub_id VARCHAR(32),
    IN p_lesson_type INT,
    IN p_schedual_type INT,
    IN p_minutes_per_lsn INT,
    IN p_subject_price DECIMAL(10,2),
    IN p_schedual_datetime DATETIME,
    IN p_bank_id VARCHAR(32),
    IN p_lsn_seq_code VARCHAR(20),
    IN p_fee_seq_code VARCHAR(20),
    IN p_pay_seq_code VARCHAR(20),
    OUT p_result INT
)
BEGIN
    -- 声明常量
    DECLARE PROCEDURE_NAME VARCHAR(100) DEFAULT 'sp_execute_advc_lsn_fee_pay';
    DECLARE PROCEDURE_ALIAS_NAME VARCHAR(100) DEFAULT '执行课费预支付处理';

    DECLARE v_lesson_id VARCHAR(50);
    DECLARE v_lsn_fee_id VARCHAR(50);
    DECLARE v_lsn_pay_id VARCHAR(50);
    DECLARE v_count INT;
    DECLARE v_lsn_month VARCHAR(7);
    DECLARE v_schedual_date DATETIME;
    DECLARE v_step_result VARCHAR(255);
    DECLARE v_current_step VARCHAR(100) DEFAULT '初始化';
    DECLARE v_error_message TEXT;
    DECLARE v_is_new_lesson BOOLEAN;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
        
        SET p_result = 0;
        ROLLBACK;
        
        INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
        VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, 
                CONCAT('发生错误: ', v_error_message));
    END;

    START TRANSACTION;

    SET v_current_step = '初始化日期和时间';
    SET v_schedual_date = p_schedual_datetime;

    -- 步骤 1: 检查 v_info_lesson 表
    SET v_current_step = '1 检查 v_info_lesson';
    SELECT COUNT(*) INTO v_count
    FROM v_info_lesson
    WHERE stu_id = p_stu_id
    AND subject_id = p_subject_id
    AND subject_sub_id = p_subject_sub_id
    AND lesson_type = p_lesson_type
    AND schedual_type = p_schedual_type
    AND class_duration = p_minutes_per_lsn
    AND schedual_date = v_schedual_date;

    IF v_count > 0 THEN
        SELECT lesson_id INTO v_lesson_id
        FROM v_info_lesson
        WHERE stu_id = p_stu_id
        AND subject_id = p_subject_id
        AND subject_sub_id = p_subject_sub_id
        AND lesson_type = p_lesson_type
        AND schedual_type = p_schedual_type
        AND class_duration = p_minutes_per_lsn
        AND schedual_date = v_schedual_date
        LIMIT 1;
        SET v_step_result = CONCAT('本月既存的lesson_id: ', v_lesson_id);
        SET v_is_new_lesson = FALSE;
    ELSE
        SET v_lesson_id = CONCAT(p_lsn_seq_code, nextval(p_lsn_seq_code));
        SET v_step_result = CONCAT('自动采番的lesson_id: ', v_lesson_id);
        SET v_is_new_lesson = TRUE;
    END IF;

    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    -- 步骤 2: 插入到 t_info_lesson（仅对新lesson执行）
    IF v_is_new_lesson THEN
        SET v_current_step = '2 插入到 t_info_lesson';
        INSERT INTO t_info_lesson (
            lesson_id, stu_id, subject_id, subject_sub_id, 
            class_duration, lesson_type, schedual_type, schedual_date
        ) VALUES (
            v_lesson_id, p_stu_id, p_subject_id, p_subject_sub_id,
            p_minutes_per_lsn, p_lesson_type, p_schedual_type, v_schedual_date
        );

        SET v_step_result = IF(ROW_COUNT() > 0, '成功', '插入失败');
        INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
        VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);
    END IF;

    -- 步骤 3: 插入到 t_info_lesson_fee
    SET v_current_step = '3 插入到 t_info_lesson_fee';
    SET v_lsn_fee_id = CONCAT(p_fee_seq_code, nextval(p_fee_seq_code));
    SET v_lsn_month = DATE_FORMAT(v_schedual_date, '%Y-%m');

    INSERT INTO t_info_lesson_fee (
        lsn_fee_id, lesson_id, pay_style, lsn_fee, lsn_month, own_flg
    ) VALUES (
        v_lsn_fee_id, v_lesson_id, 1, p_subject_price, v_lsn_month, 1
    );

    SET v_step_result = IF(ROW_COUNT() > 0, '成功', '插入失败');
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    -- 步骤 4: 插入到 t_info_lesson_pay
    SET v_current_step = '4 插入到 t_info_lesson_pay';
    SET v_lsn_pay_id = CONCAT(p_pay_seq_code, nextval(p_pay_seq_code));

    INSERT INTO t_info_lesson_pay (
        lsn_pay_id, lsn_fee_id, lsn_pay, bank_id, pay_month, pay_date
    ) VALUES (
        v_lsn_pay_id,
        v_lsn_fee_id,
        p_subject_price * 4, -- 月计划课程是按月缴费，所以应缴纳4节课的价钱
        p_bank_id,
        v_lsn_month,
        CURDATE()
    );

    SET v_step_result = IF(ROW_COUNT() > 0, '成功', '插入失败');
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    -- 步骤 5: 插入到 t_info_lsn_fee_advc_pay
    SET v_current_step = '5 插入到 t_info_lsn_fee_advc_pay';
    INSERT INTO t_info_lsn_fee_advc_pay (
        lesson_id, lsn_fee_id, lsn_pay_id, advance_pay_date
    ) VALUES (
        v_lesson_id,
        v_lsn_fee_id,
        v_lsn_pay_id,
        CURDATE()
    );

    SET v_step_result = IF(ROW_COUNT() > 0, '成功', '插入失败');
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, v_step_result);

    COMMIT;
    SET p_result = 1;

    SET v_current_step = '6 存储过程完成';
    INSERT INTO t_sp_execution_log (procedure_name, procedure_alias_name, step_name, result)
    VALUES (PROCEDURE_NAME, PROCEDURE_ALIAS_NAME, v_current_step, '成功');

END //
DELIMITER ;