-- 📱手机端用视图 课程进度统计，用该视图取出的数据初期化手机页面的graph图
-- use prod_KNStudent;
DROP VIEW IF EXISTS v_info_lsn_statistics_by_stuid;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost
    SQL SECURITY DEFINER
VIEW v_info_lsn_statistics_by_stuid AS
SELECT 
        stu_id AS stu_id,
        stu_name AS stu_name,
        subject_name AS subject_name,
        subject_id AS subject_id,
        subject_sub_id AS subject_sub_id,
        subject_sub_name AS subject_sub_name,
        lesson_type AS lesson_type,
        SUM(lsn_count) AS lsn_count,
        lsn_month AS lsn_month
    FROM
        v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
    GROUP BY stu_id , 
	         stu_name , 
             subject_name , 
             subject_id , 
             subject_sub_id , 
             subject_sub_name , 
             lesson_type , 
             lsn_month
    ORDER BY lsn_month , 
			 subject_id , 
             subject_sub_id