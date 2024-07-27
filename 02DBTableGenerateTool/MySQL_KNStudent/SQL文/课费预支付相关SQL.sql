-- 获取 doc 表中的数据，而这些数据在 lsn 表中不存在
(SELECT 
    doc.stu_id,
    doc.stu_name,
    doc.subject_id,
    doc.subject_name,
    doc.subject_sub_id,
    doc.subject_sub_name,
    '' as schedual_date
FROM (
		-- 查找每个学生每个科目的最新签到日期
		SELECT 
			stu_id,
			stu_name,
			subject_id,
			subject_name,
			subject_sub_id,
			subject_sub_name,
			MAX(schedual_date) AS schedual_date
		FROM v_info_lesson
		WHERE scanQR_date IS NOT NULL
		GROUP BY 
			stu_id,
			stu_name,
			subject_id,
			subject_name,
			subject_sub_id,
			subject_sub_name
		) lsn
		RIGHT JOIN (
		-- 从学生档案表里获取所有课程记录
		SELECT *
		FROM v_latest_subject_info_from_student_document
		) doc
		ON lsn.stu_id = doc.stu_id 
		AND lsn.subject_id = doc.subject_id
		AND lsn.subject_sub_id = doc.subject_sub_id
		WHERE lsn.stu_id IS NULL
		  AND doc.stu_id = 'kn-stu-3'
)
UNION ALL
(SELECT stu_id,stu_name,subject_id,subject_name,subject_sub_id,subject_sub_name,MAX(schedual_date) AS schedual_date
	FROM v_info_lesson
	WHERE stu_id = 'kn-stu-3'
	  AND scanQR_date IS NOT NULL
	group by stu_id,stu_name,subject_id,subject_name,subject_sub_id,subject_sub_name
);
