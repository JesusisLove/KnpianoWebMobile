/**
*视图v_info_lesson_include_extra2sche是在v_info_lesson视图的代码基础上作成的，该视图
*只针对加课换成了正课后，对加课换正课的记录进行了处理，
*执行v_info_lesson，可以看到换正课之前,该月加课记录的真实记录（相当于姑娘化妆前的样貌）
*执行v_info_lesson_include_extra2sche，只能看到加课换成正课之后，变成正课的样貌（相当于姑娘化妆后的样貌）
*如果加课换正课赶上了课程升级（比如，去年12月份学的5级的加课换成今年1月份正课，但是，1月份开始进入6级的课程，
*那么，换到1月正课的那个加课将被视为6级课程）。t_info_lesson_extra_to_sche表里
*会记录该加课的课程级别和换正课后的课程级别。
*该视图只针对加课换正课的数据处理，对其调课记录，正课记录没有影响。
*/
-- use prod_KNStudent;
use KNStudent;
DROP VIEW IF EXISTS v_info_lesson_and_extraToScheDataCorrect;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_info_lesson_and_extraToScheDataCorrect AS
    SELECT 
        lsn.lesson_id AS lesson_id,
        lsn.subject_id AS subject_id,
        eda.subject_name AS subject_name,
        lsn.subject_sub_id AS subject_sub_id,
        eda.subject_sub_name AS subject_sub_name,
        lsn.stu_id AS stu_id,
		case when mst.del_flg = 1 then  CONCAT(mst.stu_name, '(已退学)')
				else mst.stu_name
		end AS stu_name,
        lsn.class_duration AS class_duration,
        lsn.schedual_type AS schedual_type,
        schedual_date,
        lsn_adjusted_date,
        lsn.scanqr_date,
        original_schedual_date,
        lesson_type,
        mst.del_flg AS del_flg,
        lsn.create_date AS create_date,
        lsn.update_date AS update_date
    FROM
        (
			SELECT 
				lsn.lesson_id AS lesson_id,
				lsn.subject_id AS subject_id,
				lsn.subject_sub_id AS subject_sub_id,
				lsn.stu_id AS stu_id,
				lsn.class_duration AS class_duration,
				lsn.schedual_type AS schedual_type,
				lsn.schedual_date,
				lsn_adjusted_date,
				lsn.scanqr_date,
                null as original_schedual_date,
                lesson_type,
				lsn.create_date AS create_date,
				lsn.update_date AS update_date
			FROM
				t_info_lesson lsn 
			where extra_to_dur_date is null -- 非加课换正课记录
			UNION ALL
			SELECT 
				lsn.lesson_id  AS lesson_id,
				lsn.subject_id AS subject_id,
				extr.new_subject_sub_id AS subject_sub_id,
                lsn.stu_id AS stu_id,
				lsn.class_duration AS class_duration,
				lsn.schedual_type AS schedual_type,
                extra_to_dur_date as schedual_date,
				null  AS lsn_adjusted_date,-- 成了正课记录的情况下，就让调课日期为null，这样手机页面的加课换正课记录就不会再显示调课日期了👍
				lsn.scanqr_date,
				lsn.schedual_date AS original_schedual_date,
				1 AS lesson_type,-- 加课换正课的场合，因为已经成为其他日期的正课，所以强行成为正课区分
				lsn.create_date AS create_date,
				lsn.update_date AS update_date 
			from t_info_lesson lsn
			inner join t_info_lesson_extra_to_sche extr 
			on extr.lesson_id = lsn.lesson_id and lsn.extra_to_dur_date is not null
        )lsn
        INNER JOIN t_mst_student mst ON lsn.stu_id = mst.stu_id
        INNER JOIN v_info_subject_edaban eda ON lsn.subject_id = eda.subject_id
											AND lsn.subject_sub_id = eda.subject_sub_id