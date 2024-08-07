DROP VIEW IF EXISTS v_info_lesson;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_info_lesson AS
    SELECT 
        a.lesson_id AS lesson_id,
        a.subject_id AS subject_id,
        c.subject_name AS subject_name,
        a.subject_sub_id AS subject_sub_id,
        c.subject_sub_name AS subject_sub_name,
        a.stu_id AS stu_id,
        case when b.del_flg = 1 then  CONCAT(b.stu_name, '(已退学)')
             else b.stu_name
        end AS stu_name,
        a.class_duration AS class_duration,
        a.lesson_type AS lesson_type,
        a.schedual_type AS schedual_type,
        a.schedual_date AS schedual_date,
        a.scanqr_date AS scanQR_date,
        a.lsn_adjusted_date AS lsn_adjusted_date,
        a.extra_to_dur_date AS extra_to_dur_date,
        b.del_flg AS del_flg,
        a.create_date AS create_date,
        a.update_date AS update_date
    FROM
        ((t_info_lesson a
        INNER JOIN t_mst_student b ON ((a.stu_id = b.stu_id)))
        INNER JOIN v_info_subject_edaban c ON (((a.subject_id = c.subject_id)
            AND (a.subject_sub_id = c.subject_sub_id))))