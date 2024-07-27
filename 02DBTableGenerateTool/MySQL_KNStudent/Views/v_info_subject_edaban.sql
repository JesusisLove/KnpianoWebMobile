CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `v_info_subject_edaban` AS
    SELECT 
        `eda`.`subject_id` AS `subject_id`,
        `sub`.`subject_name` AS `subject_name`,
        `eda`.`subject_sub_id` AS `subject_sub_id`,
        `eda`.`subject_sub_name` AS `subject_sub_name`,
        `eda`.`subject_price` AS `subject_price`,
        `eda`.`del_flg` AS `del_flg`,
        `eda`.`create_date` AS `create_date`,
        `eda`.`update_date` AS `update_date`
    FROM
        (`t_info_subject_edaban` `eda`
        LEFT JOIN `t_mst_subject` `sub` ON (((`eda`.`subject_id` = `sub`.`subject_id`)
            AND (`eda`.`del_flg` = 0)
            AND (`sub`.`del_flg` = 0))))