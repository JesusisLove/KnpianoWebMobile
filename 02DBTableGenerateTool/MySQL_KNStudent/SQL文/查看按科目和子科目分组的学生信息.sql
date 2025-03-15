use prod_KNStudent;

select 
 subject_id
,subject_name
,subject_sub_id
,subject_sub_name
,stu_id
,stu_name
,lesson_fee
,lesson_fee_adjusted
,minutes_per_lsn
from v_latest_subject_info_from_student_document doc
where exists(
			select 1 from t_mst_student mst where mst.stu_id  = doc.stu_id and mst.del_flg = 0
            )
order by CAST(SUBSTRING_INDEX(subject_sub_id, '-', -1) as SIGNED), cast(SUBSTRING_INDEX(subject_sub_id, '-', -1)as signed),stu_name
;