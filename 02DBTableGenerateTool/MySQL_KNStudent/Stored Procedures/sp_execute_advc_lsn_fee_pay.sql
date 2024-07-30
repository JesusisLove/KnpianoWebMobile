DELIMITER //

CREATE PROCEDURE sp_execute_advc_lsn_fee_pay(
    IN stu_id 			VARCHAR(32),
    IN subject_id 		VARCHAR(32),
    IN subject_sub_id 	VARCHAR(32),
    IN lesson_type 		INT,
    IN schedual_type 	INT,
    IN minutes_per_lsn 	INT,
    IN subject_price 	DECIMAL(10,2),
    IN schedual_date 	DATE,
    IN bank_id 			VARCHAR(32),
    IN lsn_seq_code 	VARCHAR(20),
    IN fee_seq_code 	VARCHAR(20),
    IN pay_seq_code 	VARCHAR(20),
    OUT p_result INT
)
BEGIN
    DECLARE v_lesson_id VARCHAR(50);
    DECLARE v_lsn_fee_id VARCHAR(50);
    DECLARE v_lsn_pay_id VARCHAR(50);
    DECLARE v_count INT;
    DECLARE v_lsn_month VARCHAR(7);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        SET p_result = 0;  -- 设置失败标志
        ROLLBACK;  -- 发生异常时回滚事务
    END;

    START TRANSACTION;  -- 开始事务

    -- 1-1. 从v_info_lesson表里抽出数据
    SELECT COUNT(*) INTO v_count
    FROM v_info_lesson
    WHERE stu_id = stu_id
    AND subject_id = subject_id
    AND subject_sub_id = subject_sub_id
    AND lesson_type = lesson_type
    AND schedual_type = schedual_type
    AND minutes_per_lsn = minutes_per_lsn
    AND schedual_date = schedual_date;

    -- 1-2 和 1-3. 插入课程表
    IF v_count > 0 THEN
        -- 如果有预先排好的课，获取lesson_id
        SELECT lesson_id INTO v_lesson_id
        FROM v_info_lesson
        WHERE stu_id = stu_id
        AND subject_id = subject_id
        AND subject_sub_id = subject_sub_id
        AND lesson_type = lesson_type
        AND schedual_type = schedual_type
        AND minutes_per_lsn = minutes_per_lsn
        AND schedual_date = schedual_date
        LIMIT 1;
    ELSE
        -- 如果没有预先排好的课，生成新的lesson_id
        SET v_lesson_id = CONCAT(lsn_seq_code, nextval(lsn_seq_code));
    END IF;

    -- 插入课程表
    INSERT INTO t_info_lesson (
        lesson_id, stu_id, subject_id, subject_sub_id, 
        class_duration, lesson_type, schedual_type, schedual_date
    ) VALUES (
        v_lesson_id, stu_id, subject_id, subject_sub_id,
        minutes_per_lsn, lesson_type, schedual_type, schedual_date
    );

    -- 2-1. 插入课费表
    SET v_lsn_fee_id = CONCAT(fee_seq_code, nextval(fee_seq_code));
    SET v_lsn_month = DATE_FORMAT(schedual_date, '%Y-%m');

    INSERT INTO t_info_lesson_fee (
        lsn_fee_id, lesson_id, pay_style, lsn_fee, lsn_month, own_flg
    ) VALUES (
        v_lsn_fee_id, v_lesson_id, 1, subject_price, v_lsn_month, 1
    );

    -- 2-2. 插入精算表
    SET v_lsn_pay_id = CONCAT(pay_seq_code, nextval(pay_seq_code));

    INSERT INTO t_info_lesson_pay (
        lsn_pay_id, lsn_fee_id, lsn_pay, bank_id, pay_month, pay_date
    ) VALUES (
        v_lsn_pay_id,
        v_lsn_fee_id,
        subject_price,
        bank_id,
        v_lsn_month,
        NOW()
    );

    -- 2-3. 插入预支付表
    INSERT INTO t_info_lsn_fee_advc_pay (
        lesson_id, lsn_fee_id, lsn_pay_id, advance_pay_date
    ) VALUES (
        v_lesson_id,
        v_lsn_fee_id,
        v_lsn_pay_id,
        NOW()
    );

    COMMIT;  -- 提交事务
    SET p_result = 1;  -- 设置成功标志

END //

DELIMITER ;