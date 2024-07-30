DELIMITER //

DROP PROCEDURE IF EXISTS sp_execute_advc_lsn_fee_pay //

CREATE PROCEDURE sp_execute_advc_lsn_fee_pay(
    IN p_stu_id VARCHAR(32),
    IN p_subject_id VARCHAR(32),
    IN p_subject_sub_id VARCHAR(32),
    IN p_lesson_type INT,
    IN p_schedual_type INT,
    IN p_minutes_per_lsn INT,
    IN p_subject_price DECIMAL(10,2),
    IN p_schedual_datetime DATETIME,
    IN p_bank_id VARCHAR(32),
    IN p_lsn_seq_code VARCHAR(20),
    IN p_fee_seq_code VARCHAR(20),
    IN p_pay_seq_code VARCHAR(20),
    OUT p_result INT
)
BEGIN
    DECLARE v_lesson_id VARCHAR(50);
    DECLARE v_lsn_fee_id VARCHAR(50);
    DECLARE v_lsn_pay_id VARCHAR(50);
    DECLARE v_count INT;
    DECLARE v_lsn_month VARCHAR(7);
    DECLARE v_schedual_date DATETIME;
    DECLARE v_step_result VARCHAR(255);
    DECLARE v_current_step VARCHAR(100) DEFAULT 'Initialization';
    DECLARE v_error_message TEXT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_error_message = MESSAGE_TEXT;
        
        SET p_result = 0;
        ROLLBACK;
        
        INSERT INTO t_sp_execution_log (procedure_name, step_name, result)
        VALUES ('sp_execute_advc_lsn_fee_pay', v_current_step, 
                CONCAT('Error occurred: ', v_error_message));
    END;

    START TRANSACTION;

    SET v_current_step = 'Initialize date and time';
    SET v_schedual_date = p_schedual_datetime;

    -- Step 1: Check v_info_lesson table
    SET v_current_step = 'Check v_info_lesson';
    SELECT COUNT(*) INTO v_count
    FROM v_info_lesson
    WHERE stu_id = p_stu_id
    AND subject_id = p_subject_id
    AND subject_sub_id = p_subject_sub_id
    AND lesson_type = p_lesson_type
    AND schedual_type = p_schedual_type
    AND class_duration = p_minutes_per_lsn
    AND schedual_date = v_schedual_date;

    IF v_count > 0 THEN
        SELECT lesson_id INTO v_lesson_id
        FROM v_info_lesson
        WHERE stu_id = p_stu_id
        AND subject_id = p_subject_id
        AND subject_sub_id = p_subject_sub_id
        AND lesson_type = p_lesson_type
        AND schedual_type = p_schedual_type
        AND class_duration = p_minutes_per_lsn
        AND schedual_date = v_schedual_date
        LIMIT 1;
        SET v_step_result = 'Existing lesson found';
    ELSE
        SET v_lesson_id = CONCAT(p_lsn_seq_code, nextval(p_lsn_seq_code));
        SET v_step_result = 'New lesson_id generated';
    END IF;

    INSERT INTO t_sp_execution_log (procedure_name, step_name, result)
    VALUES ('sp_execute_advc_lsn_fee_pay', v_current_step, v_step_result);

    -- Step 2: Insert into t_info_lesson
    SET v_current_step = 'Insert into t_info_lesson';
    INSERT INTO t_info_lesson (
        lesson_id, stu_id, subject_id, subject_sub_id, 
        class_duration, lesson_type, schedual_type, schedual_date
    ) VALUES (
        v_lesson_id, p_stu_id, p_subject_id, p_subject_sub_id,
        p_minutes_per_lsn, p_lesson_type, p_schedual_type, v_schedual_date
    );

    SET v_step_result = IF(ROW_COUNT() > 0, 'Success', 'Insert failed');
    INSERT INTO t_sp_execution_log (procedure_name, step_name, result)
    VALUES ('sp_execute_advc_lsn_fee_pay', v_current_step, v_step_result);

    -- Step 3: Insert into t_info_lesson_fee
    SET v_current_step = 'Insert into t_info_lesson_fee';
    SET v_lsn_fee_id = CONCAT(p_fee_seq_code, nextval(p_fee_seq_code));
    SET v_lsn_month = DATE_FORMAT(v_schedual_date, '%Y-%m');

    INSERT INTO t_info_lesson_fee (
        lsn_fee_id, lesson_id, pay_style, lsn_fee, lsn_month, own_flg
    ) VALUES (
        v_lsn_fee_id, v_lesson_id, 1, p_subject_price, v_lsn_month, 1
    );

    SET v_step_result = IF(ROW_COUNT() > 0, 'Success', 'Insert failed');
    INSERT INTO t_sp_execution_log (procedure_name, step_name, result)
    VALUES ('sp_execute_advc_lsn_fee_pay', v_current_step, v_step_result);

    -- Step 4: Insert into t_info_lesson_pay
    SET v_current_step = 'Insert into t_info_lesson_pay';
    SET v_lsn_pay_id = CONCAT(p_pay_seq_code, nextval(p_pay_seq_code));

    INSERT INTO t_info_lesson_pay (
        lsn_pay_id, lsn_fee_id, lsn_pay, bank_id, pay_month, pay_date
    ) VALUES (
        v_lsn_pay_id,
        v_lsn_fee_id,
        p_subject_price,
        p_bank_id,
        v_lsn_month,
        CURDATE()
    );

    SET v_step_result = IF(ROW_COUNT() > 0, 'Success', 'Insert failed');
    INSERT INTO t_sp_execution_log (procedure_name, step_name, result)
    VALUES ('sp_execute_advc_lsn_fee_pay', v_current_step, v_step_result);

    -- Step 5: Insert into t_info_lsn_fee_advc_pay
    SET v_current_step = 'Insert into t_info_lsn_fee_advc_pay';
    INSERT INTO t_info_lsn_fee_advc_pay (
        lesson_id, lsn_fee_id, lsn_pay_id, advance_pay_date
    ) VALUES (
        v_lesson_id,
        v_lsn_fee_id,
        v_lsn_pay_id,
        CURDATE()
    );

    SET v_step_result = IF(ROW_COUNT() > 0, 'Success', 'Insert failed');
    INSERT INTO t_sp_execution_log (procedure_name, step_name, result)
    VALUES ('sp_execute_advc_lsn_fee_pay', v_current_step, v_step_result);

    COMMIT;
    SET p_result = 1;

    SET v_current_step = 'Procedure Completion';
    INSERT INTO t_sp_execution_log (procedure_name, step_name, result)
    VALUES ('sp_execute_advc_lsn_fee_pay', v_current_step, 'Success');

END //

DELIMITER ;