-- 第一部分：获取学生档案中存在但在课程信息表中不存在的科目数据
(SELECT 
    doc.stu_id,
    doc.stu_name,
    doc.subject_id,  -- 添加这一列
    doc.subject_name,
    doc.subject_sub_id,
    doc.subject_sub_name,
    -- 根据支付方式设置课程类型
    CASE 
        WHEN doc.pay_style = 1 THEN 1  -- 1表示按月付费的情况下，有月计划课和月加课，月加课是此次处理的对象外课程
    END as lesson_type,
    NULL AS schedual_date
FROM (
    -- 子查询：获取每个学生每个科目的最新签到日期，月加课（lesson_type != 2）
    SELECT 
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
        lesson_type,
        MAX(schedual_date) AS schedual_date
    FROM v_info_lesson
    WHERE scanQR_date IS NOT NULL and lesson_type != 2
    GROUP BY 
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        lesson_type,
        subject_sub_name
) lsn
RIGHT JOIN (
    -- 从学生档案表获取所有课程记录
    SELECT *
    FROM v_latest_subject_info_from_student_document
) doc
ON lsn.stu_id = doc.stu_id 
AND lsn.subject_id = doc.subject_id
AND lsn.subject_sub_id = doc.subject_sub_id
WHERE lsn.stu_id IS NULL
  AND doc.stu_id = 'kn-stu-3'
  AND doc.pay_style = 1)
UNION ALL
-- 第二部分：获取学生在课程信息表中的现有课程数据
(SELECT 
    stu_id,
    stu_name,
    subject_id,
    subject_name,
    subject_sub_id,
    subject_sub_name,
    lesson_type,
    MAX(schedual_date) AS schedual_date
FROM v_info_lesson
WHERE stu_id = 'kn-stu-3'
  AND scanQR_date IS NOT NULL 
  AND lesson_type = 1 -- 只选择 lesson_type = 1 的记录
GROUP BY 
    stu_id,
    stu_name,
    subject_id,
    subject_name,
    subject_sub_id,
    lesson_type,
    subject_sub_name);
    
    DELETE FROM KNStudent.t_info_lesson_pay WHERE lsn_pay_id IS NOT NULL LIMIT 1000000;
    DELETE FROM KNStudent.t_info_lesson_fee WHERE lsn_fee_id IS NOT NULL LIMIT 1000000;
    DELETE FROM KNStudent.t_info_lesson WHERE lesson_id IS NOT NULL LIMIT 1000000;
    DELETE FROM KNStudent.t_sp_execution_log where id is not null limit 1000000;