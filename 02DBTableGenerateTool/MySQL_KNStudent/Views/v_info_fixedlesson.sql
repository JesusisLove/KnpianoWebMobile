
DROP VIEW IF EXISTS v_info_fixedlesson;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_info_fixedlesson AS
        SELECT 
        a.stu_id AS stu_id,
        case when b.del_flg = 1 then  CONCAT(b.stu_name, '(已退学)')
             else b.stu_name
        end AS stu_name,
        a.subject_id AS subject_id,
        c.subject_name AS subject_name,
        a.fixed_week AS fixed_week,
        a.fixed_hour AS fixed_hour,
        a.fixed_minute AS fixed_minute,
        b.del_flg as del_flg
    FROM
        ((t_info_fixedlesson a
        JOIN t_mst_student b ON ((a.stu_id = b.stu_id)))
        JOIN t_mst_subject c ON ((a.subject_id = c.subject_id)))
;