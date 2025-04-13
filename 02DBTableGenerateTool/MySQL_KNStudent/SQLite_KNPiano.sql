

-- 创建数据库
CREATE DATABASE IF NOT EXISTS SQLite_KNPiano;
USE SQLite_KNPiano;

-- 创建表
CREATE TABLE IF NOT EXISTS `t_masterstudent` (
    `student_id` VARCHAR(50),
    `student_name` VARCHAR(100),
    `id_no` VARCHAR(50),
    `sex` CHAR(1),
    `birthday` DATE,
    `siblings` TEXT,
    `first_lesson_date` DATE,
    `piano_year_lessons` INT,
    `tel1` VARCHAR(20),
    `tel2` VARCHAR(20),
    `tel3` VARCHAR(20),
    `tel4` VARCHAR(20),
    `tel5` VARCHAR(20),
    `home_address` TEXT,
    `postal_code` VARCHAR(10),
    `icon` BLOB,
    `create_date` DATETIME,
    `del_flg` TINYINT,
    `introducer` VARCHAR(100),
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_masterintroducer` (
    `introducer_id` VARCHAR(50) NOT NULL,
    `introducer_name` VARCHAR(100),
    PRIMARY KEY(`introducer_id`)
);

CREATE TABLE IF NOT EXISTS `t_info_lesson_fee_pay` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` VARCHAR(50),
    `class_id` VARCHAR(50),
    `pianograde_id` VARCHAR(50),
    `pay_style` INT,
    `act_payment` DECIMAL(10,2),
    `act_payment_extra` DECIMAL(10,2),
    `partial_diff` DECIMAL(10,2),
    `supper_id` INT,
    `bank_id` VARCHAR(50),
    `lessonfee_month` VARCHAR(7),
    `paid_date` DATE,
    `own_fee_flg` TINYINT,
    `scan_flg` TINYINT,
    `del_flg` TINYINT,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_info_extra_has_been_paid_hst` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `lsn_fee_paid_id` VARCHAR(50) NOT NULL,
    `info_lesson_id` VARCHAR(50) NOT NULL,
    `make_dur` DECIMAL(10,2) NOT NULL,
    `make_dur_flg` TINYINT NOT NULL DEFAULT 0,
    `del_date` DATE,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_info_lesson_hour_fee_paid_hst` (
    `student_id` VARCHAR(50),
    `lesson_fee_pay_id` INT,
    `lesson_id` INT,
    `class_id` INT,
    `lesson_price` DECIMAL(10,2),
    `class_duration` INT,
    `balance_flg` TINYINT,
    `bg_color_rgb` VARCHAR(20),
    `fnt_color_rgb` VARCHAR(20),
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_info_lesson_hour_fee_pay` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` VARCHAR(50),
    `fee` DECIMAL(10,2),
    `bank_id` VARCHAR(50),
    `paid_date` DATE,
    `scan_flg` TINYINT,
    `balance_flg` TINYINT,
    `bg_color_rgb` VARCHAR(20),
    `fnt_color_rgb` VARCHAR(20),
    `del_flg` TINYINT,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_mastercolor` (
    `date_bg_fnt` VARCHAR(5),
    `color_name` VARCHAR(50),
    `red_bg` INT,
    `green_bg` INT,
    `blue_bg` INT,
    `red_fnt` INT,
    `green_fnt` INT,
    `blue_fnt` INT
);

CREATE TABLE IF NOT EXISTS `t_info_fake_lesson` (
    `student_id` VARCHAR(50) NOT NULL,
    `class_id` VARCHAR(50) NOT NULL,
    `pianograde_id` VARCHAR(50) NOT NULL,
    `extra_advance` DECIMAL(10,2) DEFAULT 0.0,
    `schedual_month` VARCHAR(7) NOT NULL,
    `paid_flg` TINYINT,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_info_lesson_hour_fee_paid_error_list` (
    `student_id` VARCHAR(50),
    `lesson_fee_pay_id` INT,
    `lesson_id` INT,
    `class_id` INT,
    `lesson_price` DECIMAL(10,2),
    `class_duration` INT
);

CREATE TABLE IF NOT EXISTS `t_info_lesson_extr_dur_middle` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `extra_can_become_dur_id` VARCHAR(100) NOT NULL,
    `schedual_date` DATE,
    `new_info_lesson_id` VARCHAR(50),
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_info_extra_can_become_dur` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `info_lesson_id` VARCHAR(50) NOT NULL,
    `make_dur` DECIMAL(10,2) NOT NULL,
    `make_dur_flg` TINYINT NOT NULL DEFAULT 0,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_info_lesson_fee` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` VARCHAR(50),
    `class_id` VARCHAR(50),
    `pianograde_id` VARCHAR(50),
    `pay_style` INT,
    `due_payment` DECIMAL(10,2),
    `due_payment_extra` DECIMAL(10,2),
    `advance_pay` DECIMAL(10,2),
    `lessonfee_month` VARCHAR(7),
    `own_fee_flg` TINYINT,
    `del_flg` TINYINT,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_info_lesson` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` VARCHAR(50),
    `class_id` VARCHAR(50),
    `pianograde_id` VARCHAR(50),
    `schedual_date` DATETIME,
    `adjusted_flg_id` VARCHAR(50),
    `classes_weekday` VARCHAR(10),
    `classes_duration` DECIMAL(10,2),
    `extra_duration` DECIMAL(10,2),
    `scanQR_date` DATETIME,
    `scanQR_weekday` VARCHAR(10),
    `memo` TEXT,
    `scan_flg` TINYINT,
    `del_flg` TINYINT,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_fixedlesson_status` (
    `week_number` INT NOT NULL,
    `start_week_date` DATE NOT NULL,
    `end_week_date` DATE NOT NULL,
    `fixed_status` TINYINT NOT NULL
);

CREATE TABLE IF NOT EXISTS `t_info_fixedlesson` (
    `student_id` VARCHAR(50) NOT NULL,
    `class_id` VARCHAR(50) NOT NULL,
    `fixed_week` VARCHAR(10) NOT NULL,
    `fixed_hour` INT,
    `fixed_minute` INT,
    `create_date` DATETIME,
    `update_date` DATETIME,
    PRIMARY KEY(`student_id`,`class_id`,`fixed_week`)
);

CREATE TABLE IF NOT EXISTS `t_info_student_document` (
    `ID` INT AUTO_INCREMENT PRIMARY KEY,
    `student_id` VARCHAR(50),
    `class_id` VARCHAR(50),
    `pianograde_id` VARCHAR(50),
    `pay_style` INT,
    `lesson_fee` DECIMAL(10,2),
    `lesson_fee_adjusted` DECIMAL(10,2),
    `extra_lesson_fee_adjusted` DECIMAL(10,2),
    `adjusted_date` DATE,
    `del_flg` TINYINT,
    `create_date` DATETIME,
    `update_date` DATETIME
);

CREATE TABLE IF NOT EXISTS `t_masterprice` (
    `class_id` VARCHAR(50) NOT NULL,
    `pianograde_id` INT NOT NULL,
    `makeprice_year` INT,
    `class_price` DECIMAL(10,2),
    PRIMARY KEY(`class_id`,`pianograde_id`,`makeprice_year`)
);

CREATE TABLE IF NOT EXISTS `t_masterpianograde` (
    `pianograde_id` INT NOT NULL,
    `pianograde_name` VARCHAR(100),
    PRIMARY KEY(`pianograde_id`)
);

CREATE TABLE IF NOT EXISTS `t_masterbanks` (
    `bank_id` VARCHAR(50) NOT NULL,
    `bank_name` VARCHAR(100),
    PRIMARY KEY(`bank_id`)
);

CREATE TABLE IF NOT EXISTS `t_masterclasses` (
    `class_id` VARCHAR(50) NOT NULL,
    `class_name` VARCHAR(100),
    PRIMARY KEY(`class_id`)
);