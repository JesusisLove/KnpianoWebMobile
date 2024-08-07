DROP VIEW IF EXISTS v_latest_subject_info_from_student_document;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER 
VIEW v_latest_subject_info_from_student_document AS 
select subquery.stu_id AS stu_id,
       subquery.stu_name AS stu_name,
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
       subquery.pay_style AS pay_style 
from (
    select v_info_student_document.stu_id AS stu_id,
    v_info_student_document.stu_name AS stu_name,
    v_info_student_document.subject_id AS subject_id,
    v_info_student_document.subject_name AS subject_name,
    v_info_student_document.subject_sub_id AS subject_sub_id,
    v_info_student_document.subject_sub_name AS subject_sub_name,
    v_info_student_document.adjusted_date AS adjusted_date,
    v_info_student_document.pay_style AS pay_style,
    v_info_student_document.minutes_per_lsn AS minutes_per_lsn,
    v_info_student_document.lesson_fee AS lesson_fee,
    v_info_student_document.lesson_fee_adjusted AS lesson_fee_adjusted,
    v_info_student_document.del_flg AS del_flg,
    v_info_student_document.create_date AS create_date,
    v_info_student_document.update_date AS update_date,
    row_number() OVER (
                        PARTITION BY v_info_student_document.stu_id,
                                     v_info_student_document.subject_id 
                                     ORDER BY v_info_student_document.adjusted_date desc 
                      )  AS rn from v_info_student_document) subquery where ((subquery.rn = 1))