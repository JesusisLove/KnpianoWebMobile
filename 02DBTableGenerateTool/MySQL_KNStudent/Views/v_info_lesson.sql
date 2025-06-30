-- 学生授業情報管理
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson`;
-- 视图
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
        CASE 
            WHEN b.del_flg = 1 THEN CONCAT(b.stu_name, '(已退学)')
            ELSE b.stu_name
        END AS stu_name,
        CASE 
            WHEN b.del_flg = 1 THEN 
                CASE 
                    WHEN b.nik_name IS NOT NULL AND b.nik_name != '' THEN CONCAT(b.nik_name, '(已退学)')
                    ELSE CONCAT(COALESCE(b.stu_name, '未知姓名'), '(已退学)')
                END              
            ELSE b.nik_name         
        END AS nik_name,
        a.class_duration AS class_duration,
        a.lesson_type AS lesson_type,
        a.schedual_type AS schedual_type,
        a.schedual_date AS schedual_date,
        a.scanqr_date AS scanQR_date,
        a.lsn_adjusted_date AS lsn_adjusted_date,
        a.extra_to_dur_date AS extra_to_dur_date,
        a.del_flg AS del_flg,
        a.memo AS memo,
        a.create_date AS create_date,
        a.update_date AS update_date
    FROM
        ((t_info_lesson a
        INNER JOIN t_mst_student b ON ((a.stu_id = b.stu_id)))
        INNER JOIN v_info_subject_edaban c ON (((a.subject_id = c.subject_id)
            AND (a.subject_sub_id = c.subject_sub_id))));