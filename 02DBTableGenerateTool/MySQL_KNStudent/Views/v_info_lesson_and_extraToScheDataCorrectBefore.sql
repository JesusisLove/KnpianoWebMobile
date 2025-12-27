/**
*视图v_info_lesson_include_extra2sche是在v_info_lesson视图的代码基础上作成的，该视图
*只针对加课换成了正课后，对加课换正课的那个记录进行了处理，
*执行视图v_info_lesson，可以看到换正课之前,该月加课记录的真实样貌（相当于姑娘结婚前在娘家的样貌）
*执行v_info_lesson_include_extra2sche，只能看到加课换成正课之后，变成正课的样貌（相当于姑娘结婚后在婆家的样貌）
*该视图只针对加课换正课的数据处理，对其调课记录，正课记录没有影响。
*/
-- use prod_KNStudent;
-- use KNStudent;
DROP VIEW IF EXISTS v_info_lesson_and_extraToScheDataCorrectBefore;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW v_info_lesson_and_extraToScheDataCorrectBefore AS
    SELECT 
        lsn.lesson_id AS lesson_id,
        lsn.subject_id AS subject_id,
        eda.subject_name AS subject_name,
        lsn.subject_sub_id AS subject_sub_id,
        eda.subject_sub_name AS subject_sub_name,
        lsn.stu_id AS stu_id,
        CASE 
            WHEN mst.del_flg = 1 THEN CONCAT(mst.stu_name, '(已退学)')
            ELSE mst.stu_name
        END AS stu_name,
        lsn.class_duration AS class_duration,
        lsn.schedual_type AS schedual_type,
        CASE 
            WHEN lsn.extra_to_dur_date IS NOT NULL THEN lsn.extra_to_dur_date -- 该记录是加课换正课记录
            ELSE lsn.schedual_date
        END as schedual_date,
        CASE 
            WHEN lsn.extra_to_dur_date IS NOT NULL THEN NULL -- 该记录是加课换正课记录，就让调课日期为null，这样手机页面的加课换正课记录就不会再显示调课日期了👍
            ELSE lsn.lsn_adjusted_date
        END AS lsn_adjusted_date,
        lsn.scanqr_date,
        CASE 
            WHEN lsn.extra_to_dur_date IS NOT NULL THEN  -- 该记录是加课换正课记录，记住原来真正签到的日期
                CASE
                    WHEN lsn.lsn_adjusted_date IS NOT NULL THEN lsn.lsn_adjusted_date  -- 调课日期是原来实际的上课日期
                    ELSE lsn.schedual_date -- 计划日期是原来实际的上课日期
                END
        END as original_schedual_date,
        CASE 
            WHEN extra_to_dur_date IS NOT NULL THEN 1 -- 该记录是加课换正课记录，因为已经成为其他日期的正课，所以强行成为正课区分
            ELSE lsn.lesson_type
        END AS lesson_type,
        mst.del_flg AS del_flg,
        lsn.create_date AS create_date,
        lsn.update_date AS update_date
    FROM
        ((t_info_lesson lsn
        INNER JOIN t_mst_student mst ON ((lsn.stu_id = mst.stu_id)))
        INNER JOIN v_info_subject_edaban eda ON (((lsn.subject_id = eda.subject_id)
            AND (lsn.subject_sub_id = eda.subject_sub_id))));