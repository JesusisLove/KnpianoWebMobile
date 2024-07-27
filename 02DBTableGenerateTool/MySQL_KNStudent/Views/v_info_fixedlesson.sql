CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_fixedlesson` AS
    SELECT 
        `a`.`stu_id` AS `stu_id`,
        `b`.`stu_name` AS `stu_name`,
        `a`.`subject_id` AS `subject_id`,
        `c`.`subject_name` AS `subject_name`,
        `a`.`fixed_week` AS `fixed_week`,
        `a`.`fixed_hour` AS `fixed_hour`,
        `a`.`fixed_minute` AS `fixed_minute`
    FROM
        ((`t_info_fixedlesson` `a`
        LEFT JOIN `t_mst_student` `b` ON ((`a`.`stu_id` = `b`.`stu_id`)))
        LEFT JOIN `t_mst_subject` `c` ON ((`a`.`subject_id` = `c`.`subject_id`)))