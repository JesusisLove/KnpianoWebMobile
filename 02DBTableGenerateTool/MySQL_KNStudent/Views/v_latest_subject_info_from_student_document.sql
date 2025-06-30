-- USE prod_KNStudent;
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
       case when subquery.del_flg = 1 then  CONCAT(subquery.nik_name, '(已退学)')
            else subquery.nik_name
       end AS nik_name,
       subquery.subject_id AS subject_id,
       subquery.subject_name AS subject_name,
       subquery.subject_sub_id AS subject_sub_id,
       subquery.subject_sub_name AS subject_sub_name,
       subquery.lesson_fee AS lesson_fee,
       subquery.lesson_fee_adjusted AS lesson_fee_adjusted,
       subquery.year_lsn_cnt AS year_lsn_cnt,
       subquery.minutes_per_lsn AS minutes_per_lsn,
       subquery.pay_style AS pay_style, 
       subquery.adjusted_date AS adjusted_date
from (
    select vDoc.stu_id AS stu_id,
            vDoc.stu_name AS stu_name,
            vDoc.nik_name AS nik_name,
            vDoc.subject_id AS subject_id,
            vDoc.subject_name AS subject_name,
            vDoc.subject_sub_id AS subject_sub_id,
            vDoc.subject_sub_name AS subject_sub_name,
            vDoc.adjusted_date AS adjusted_date,
            vDoc.pay_style AS pay_style,
            vDoc.minutes_per_lsn AS minutes_per_lsn,
            vDoc.lesson_fee AS lesson_fee,
            vDoc.lesson_fee_adjusted AS lesson_fee_adjusted,
            vDoc.year_lsn_cnt AS year_lsn_cnt,
            vDoc.del_flg AS del_flg,
            vDoc.create_date AS create_date,
            vDoc.update_date AS update_date,
            row_number() OVER (
                                PARTITION BY vDoc.stu_id,
                                            vDoc.subject_id 
                                            ORDER BY vDoc.adjusted_date desc 
                            )  AS rn 
    from v_info_student_document vDoc
        -- 价格调整日期小于系统当前日期，防止学生下一学期调整的科目不合时机的出现
    where adjusted_date <= CURDATE()
    ) subquery 
where subquery.rn = 1
;