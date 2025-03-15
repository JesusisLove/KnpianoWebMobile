SELECT * FROM prod_KNStudent.v_latest_subject_info_from_student_document;
select * from prod_KNStudent.t_info_subject_edaban;

select * from prod_KNStudent.t_info_lesson where lesson_id in ( 'kn-lsn-288','kn-lsn-409');
select stu_name, subject_name,count(subject_sub_id) from prod_KNStudent.v_info_lesson 
where schedual_date like '2024%' and lesson_type = 2 and lesson_id like 'kn-lsn-%'
group by stu_name,subject_name
;

select stu_name, subject_sub_name,class_duration,schedual_date from prod_KNStudent.v_info_lesson 
where schedual_date like '2024%' and lesson_type = 2 and lesson_id like 'kn-lsn-%'
and extra_to_dur_date is null and subject_id = 'kn-sub-1'
order by stu_name,schedual_date
;