use SQLite_KNPiano;
delete from t_masterstudent
where
    student_id is not null limit 100000;

delete from t_info_lesson_fee_pay
where
    id is not null limit 100000;

delete from t_info_extra_has_been_paid_hst
where
    id is not null limit 100000;

delete from t_info_lesson_hour_fee_paid_hst
where
    student_id is not null limit 100000;

delete from t_info_lesson_hour_fee_pay
where
    id is not null limit 100000;

delete from t_info_fake_lesson
where
    student_id is not null limit 100000;

delete from t_info_lesson_hour_fee_paid_error_list
where
    student_id is not null limit 100000;

delete from t_info_lesson_extr_dur_middle
where
    id is not null limit 100000;

delete from t_info_extra_can_become_dur
where
    id is not null limit 100000;

delete from t_info_lesson_fee
where
    id is not null limit 100000;

delete from t_info_lesson
where
    id is not null limit 100000;

delete from t_info_fixedlesson
where
    student_id is not null limit 100000;

delete from t_info_student_document
where
    id is not null limit 100000;

delete from t_masterpianograde
where
    pianograde_id is not null limit 100000;

delete from t_masterbanks
where
    bank_id is not null limit 100000;

delete from t_masterclasses
where
    class_id is not null limit 100000;

delete from t_masterprice
where
    class_id is not null limit 100000;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_extra_can_become_dur.csv'
into table t_info_extra_can_become_dur
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_fake_lesson.csv'
into table t_info_fake_lesson
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_fixedlesson.csv'
into table t_info_fixedlesson
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_lesson_extr_dur_middle.csv'
into table t_info_lesson_extr_dur_middle
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_lesson.csv'
into table t_info_lesson
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_lesson_fee.csv'
into table t_info_lesson_fee
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_lesson_fee_pay.csv'
into table t_info_lesson_fee_pay
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_lesson_hour_fee_paid_hst.csv'
into table t_info_lesson_hour_fee_paid_hst
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_lesson_hour_fee_pay.csv'
into table t_info_lesson_hour_fee_pay
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_info_student_document.csv'
into table t_info_student_document
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_masterbanks.csv'
into table t_masterbanks
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_masterclasses.csv'
into table t_masterclasses
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_masterpianograde.csv'
into table t_masterpianograde
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_masterprice.csv'
into table t_masterprice
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data local infile '/users/kazuyoshi/synologydrive/02_个人篇/203_工作/230302_webkuanniproject/02knpiano案件管理/070_移行/旧数据库/datacsv/t_masterstudent.csv'
into table t_masterstudent
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;
