CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_student_bank` AS
    SELECT 
        `stubnk`.`stu_id` AS `stu_id`,
        `stu`.`stu_name` AS `stu_name`,
        `stubnk`.`bank_id` AS `bank_id`,
        `bnk`.`bank_name` AS `bank_name`,
        `stubnk`.`del_flg` AS `del_flg`,
        `stubnk`.`create_date` AS `create_date`,
        `stubnk`.`update_date` AS `update_date`
    FROM
        ((`t_info_student_bank` `stubnk`
        LEFT JOIN `t_mst_bank` `bnk` ON (((`stubnk`.`bank_id` = `bnk`.`bank_id`)
            AND (`bnk`.`del_flg` = 0))))
        LEFT JOIN `t_mst_student` `stu` ON (((`stubnk`.`stu_id` = `stu`.`stu_id`)
            AND (`stu`.`del_flg` = 0))))