USE KNStudent;
DELETE FROM t_sp_execution_log 
WHERE id IS NOT NULL LIMIT 1000000;
DELETE FROM t_info_lsn_fee_advc_pay 
WHERE lesson_id IS NOT NULL LIMIT 1000000;
TRUNCATE TABLE t_fixedlesson_status;
DELETE FROM t_info_lesson_pay 
WHERE lsn_pay_id IS NOT NULL LIMIT 1000000;
DELETE FROM t_info_lesson_fee 
WHERE lsn_fee_id IS NOT NULL LIMIT 1000000;
DELETE FROM t_info_lesson 
WHERE lesson_id IS NOT NULL LIMIT 1000000;
DELETE FROM t_info_student_document 
WHERE stu_id IS NOT NULL AND subject_id IS NOT NULL AND subject_sub_id IS NOT NULL AND adjusted_date IS NOT NULL LIMIT 1000000;
DELETE FROM t_info_fixedlesson 
WHERE stu_id IS NOT NULL AND subject_id IS NOT NULL AND fixed_week IS NOT NULL LIMIT 1000000;
DELETE FROM t_info_student_bank 
WHERE stu_id IS NOT NULL AND bank_id IS NOT NULL LIMIT 1000000;
DELETE FROM t_info_subject_edaban 
WHERE subject_id IS NOT NULL AND subject_sub_id IS NOT NULL LIMIT 1000000;
DELETE FROM t_mst_bank 
WHERE bank_id IS NOT NULL LIMIT 1000000;
DELETE FROM t_mst_subject 
WHERE subject_id IS NOT NULL LIMIT 1000000;
DELETE FROM t_mst_student 
WHERE stu_id IS NOT NULL LIMIT 1000000;
DELETE FROM sequence 
WHERE seqid IS NOT NULL LIMIT 1000000;
