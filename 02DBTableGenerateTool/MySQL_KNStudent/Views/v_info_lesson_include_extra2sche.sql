/**
*视图v_info_lesson_include_extra2sche是在v_info_lesson视图的代码基础上作成的，该视图
*只针对加课换成了正课后，对加课换正课的那个记录进行了处理，
*执行视图v_info_lesson，可以看到换正课之前,该月加课记录的真实样貌（相当于姑娘结婚前在娘家的样貌）
*执行v_info_lesson_include_extra2sche，只能看到加课换成正课之后，变成正课的样貌（相当于姑娘结婚后在婆家的样貌）
*该视图只针对加课换正课的数据处理，对其调课记录，正课记录没有影响。
*/
DROP VIEW IF EXISTS v_info_lesson_include_extra2sche;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_info_lesson_include_extra2sche AS
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
        lsn.schedual_date AS schedual_date,
        lsn.lsn_adjusted_date AS lsn_adjusted_date,
        case 
			when lsn.extra_to_dur_date is not null 
            then lsn.extra_to_dur_date -- 加课换正课的场合，加课转正课的那个日期成为，换正课日期的签到日期
            else lsn.scanqr_date -- 上记以外的场合，原来的签到日期还是原来的签到日期
        end AS scanQR_date,
        case 
			when lsn.extra_to_dur_date is not null 
			then lsn.scanqr_date -- 加课换正课的场合，记住原来真正签到的日期
        end as original_scanqr_date,
        case 
			when extra_to_dur_date is not null 
            then 1 -- 加课换正课的场合，因为已经成为其他日期的正课，所以强行成为正课区分
            else lsn.lesson_type -- 上记以外的场合
        end AS lesson_type,
        mst.del_flg AS del_flg,
        lsn.create_date AS create_date,
        lsn.update_date AS update_date
    FROM
        ((t_info_lesson lsn
        INNER JOIN t_mst_student mst ON ((lsn.stu_id = mst.stu_id)))
        INNER JOIN v_info_subject_edaban eda ON (((lsn.subject_id = eda.subject_id)
            AND (lsn.subject_sub_id = eda.subject_sub_id))))