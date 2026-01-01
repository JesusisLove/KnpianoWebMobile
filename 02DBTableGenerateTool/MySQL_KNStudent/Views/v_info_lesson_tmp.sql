-- 临时课程信息视图
-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_info_lesson_tmp`;
-- 视图
CREATE
    ALGORITHM = UNDEFINED
    DEFINER = `root`@`%`
    SQL SECURITY DEFINER
VIEW v_info_lesson_tmp AS
    SELECT
        a.lsn_tmp_id AS lsn_tmp_id,
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
        a.schedual_date AS schedual_date,
        a.scanqr_date AS scanQR_date,
        a.del_flg AS del_flg,
        a.create_date AS create_date,
        a.update_date AS update_date
    FROM
        ((t_info_lesson_tmp a
        INNER JOIN t_mst_student b ON ((a.stu_id = b.stu_id)))
        INNER JOIN v_info_subject_edaban c ON (((a.subject_id = c.subject_id)
            AND (a.subject_sub_id = c.subject_sub_id))));