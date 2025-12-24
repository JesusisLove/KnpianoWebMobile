DELIMITER //

DROP PROCEDURE IF EXISTS sp_cancel_tmp_lesson_info//

CREATE PROCEDURE sp_cancel_tmp_lesson_info(
    IN p_lsn_tmp_id VARCHAR(32),
    IN p_lsn_fee_id VARCHAR(32)
)
BEGIN
    DECLARE v_own_flg CHAR(1);
    DECLARE v_count INT;

    -- 异常处理：如果发生错误则回滚
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 检查课费记录是否存在并获取结算状态
    SELECT own_flg INTO v_own_flg
    FROM t_info_lesson_fee
    WHERE lsn_fee_id = p_lsn_fee_id;

    -- 如果课费记录不存在
    IF v_own_flg IS NULL THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '未找到对应的课费记录！';
    END IF;

    -- 如果课费已结算，不允许撤销
    IF v_own_flg = '1' THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '该课费已结算，无法撤销！';
    END IF;

    -- 删除课费表记录
    DELETE FROM t_info_lesson_fee
    WHERE lsn_fee_id = p_lsn_fee_id;

    -- 删除临时课程表记录
    DELETE FROM t_info_lesson_tmp
    WHERE lsn_tmp_id = p_lsn_tmp_id;

    COMMIT;

    -- 返回成功标识
    SELECT 'SUCCESS' AS result;

END//

DELIMITER ;
