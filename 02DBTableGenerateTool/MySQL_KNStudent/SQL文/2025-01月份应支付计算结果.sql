-- 应支付计算结果 12370
/* 以剔除掉加课换正课后，所有签到了的学生的课为基准，计算学生某个月的应支付的合计计算
 */
select sum(lsn_fee) from (
select stu_id,stu_name,subject_id,subject_name,lesson_type,lsn_price,
sum(lsn_count) as lsn_count,
case when lesson_type = 1 then lsn_price * 4
     else sum(lsn_price * lsn_count)
end as lsn_fee
 from (
	select lsn.stu_id, lsn.stu_name,lsn.subject_id,lsn.subject_name,lesson_type,
	lsn.class_duration/doc.minutes_per_lsn as lsn_count,
	case when doc.lesson_fee_adjusted is not null then doc.lesson_fee_adjusted
		 else doc.lesson_fee
	end as lsn_price
	from v_info_lesson lsn
	inner join 
	v_latest_subject_info_from_student_document doc
	on lsn.stu_id = doc.stu_id and lsn.subject_id = doc.subject_id and lsn.subject_sub_id = doc.subject_sub_id
	where left(lsn.schedual_date,7) = '2025-01' and scanQR_date is not null and extra_to_dur_date is null
	 -- and lsn.stu_id in(select stu_id from t_mst_student where del_flg = 0)
	 -- and lsn.stu_id = 'kn-stu-31'
) T1
group by stu_id,stu_name,subject_id,subject_name,lesson_type,lsn_price
)TT
;


-- select stu_id,stu_name,subject_id,subject_sub_id,subject_sub_name,class_duration,lesson_type from v_info_lesson;
 select * from v_info_lesson where stu_id ='kn-stu-25' and left(schedual_date,7) = '2025-01'
 and scanQR_date is not null
 order by subject_id;
 select * from v_latest_subject_info_from_student_document where stu_id = 'kn-stu-31';
;