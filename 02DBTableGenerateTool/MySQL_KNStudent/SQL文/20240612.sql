
	select lsnfee.lsn_fee_id
		  ,lsnfee.stu_id
		  ,lsnfee.stu_name
		  ,lsnfee.subject_id
		  ,lesson.subject_sub_id
		  ,lsnfee.subject_name
		  ,lesson.subject_sub_name
		  ,lesson.lesson_type
		  ,lsnfee.pay_style
		  ,lsnfee.lsn_month
		  ,lsnfee.own_flg
		  ,sum(lsnfee.lsn_count) as lsn_count
		 ,((lsnfee.lsn_fee/lsn_count) * 4) as lsn_fee

		from (
			KNStudent.v_info_lesson_fee_connect_lsn lsnfee
			inner join 
			KNStudent.v_info_lesson lesson
			on lsnfee.lesson_id = lesson.lesson_id
			and lsnfee.own_flg = 0 
            and lesson.lesson_type = 1 
            AND lsnfee.pay_style =1
		)          
		group by lsnfee.lsn_fee_id
				,lsnfee.stu_id
				,lsnfee.stu_name
				,lsnfee.subject_id
				,lesson.subject_sub_id
				,lsnfee.subject_name
				,lesson.subject_sub_name
				,lesson.lesson_type
				,lsnfee.pay_style
				,lsnfee.lsn_month
                ,lsn_fee
                ,lsn_count
				,lsnfee.own_flg
                ;
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



select lsn_fee_id
	  ,stu_id
	  ,stu_name
	  ,subject_id
	  ,subject_sub_id
	  ,subject_name
	  ,subject_sub_name
	  ,lesson_type
	  ,pay_style
	  ,lsn_month
	  ,own_flg
	  ,sum(lsn_count) as lsn_count
	  ,sum(lsn_fee) as lsn_fee
from(
			
	select lsnfee.lsn_fee_id
		  ,lsnfee.stu_id
		  ,lsnfee.stu_name
		  ,lsnfee.subject_id
		  ,lesson.subject_sub_id
		  ,lsnfee.subject_name
		  ,lesson.subject_sub_name
		  ,lesson.lesson_type
		  ,lsnfee.pay_style
		  ,lsnfee.lsn_month
		  ,lsnfee.own_flg
		  ,sum(lsnfee.lsn_count) as lsn_count
		  -- 按月交费且是计划课时
		  ,sum(case 
				when (lesson.lesson_type = 1 and lsnfee.pay_style = 1 )
				then ((lsnfee.lsn_fee/lsn_count) * 4) 
				else 0
				end)/4  as lsn_fee
		from (
			KNStudent.v_info_lesson_fee_connect_lsn lsnfee
			inner join 
			KNStudent.v_info_lesson lesson
			on lsnfee.lesson_id = lesson.lesson_id
			and lsnfee.own_flg = 0 
		)          
		group by lsnfee.lsn_fee_id
				,lsnfee.stu_id
				,lsnfee.stu_name
				,lsnfee.subject_id
				,lesson.subject_sub_id
				,lsnfee.subject_name
				,lesson.subject_sub_name
				,lesson.lesson_type
				,lsnfee.pay_style
				,lsnfee.lsn_month
				,lsnfee.own_flg
	union all
	select lsnfee.lsn_fee_id
		  ,lsnfee.stu_id
		  ,lsnfee.stu_name
		  ,lsnfee.subject_id
		  ,lesson.subject_sub_id
		  ,lsnfee.subject_name
		  ,lesson.subject_sub_name
		  ,lesson.lesson_type
		  ,lsnfee.pay_style
		  ,lsnfee.lsn_month
		  ,lsnfee.own_flg
		  ,sum(lsnfee.lsn_count) as lsn_count
		  -- 【按月交费且是计划课时】以外
		  ,sum(case 
				when (lesson.lesson_type = 1 and lsnfee.pay_style = 1 )
				then 0
				else (lsnfee.lsn_fee) 
				end)  as lsn_fee
		from (
			KNStudent.v_info_lesson_fee_connect_lsn lsnfee
			inner join 
			KNStudent.v_info_lesson lesson
			on lsnfee.lesson_id = lesson.lesson_id
			and lsnfee.own_flg = 0 
		)          
		group by lsnfee.lsn_fee_id
				,lsnfee.stu_id
				,lsnfee.stu_name
				,lsnfee.subject_id
				,lesson.subject_sub_id
				,lsnfee.subject_name
				,lesson.subject_sub_name
				,lesson.lesson_type
				,lsnfee.pay_style
				,lsnfee.lsn_month
                ,lsnfee.own_flg
) a
group by lsn_fee_id
		  ,stu_id
		  ,stu_name
		  ,subject_id
		  ,subject_sub_id
		  ,subject_name
		  ,subject_sub_name
		  ,lesson_type
		  ,pay_style
		  ,lsn_month
		  ,own_flg