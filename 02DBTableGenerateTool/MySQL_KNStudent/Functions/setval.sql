-- CREATE DEFINER=`root`@`%` FUNCTION `setval`(seq_id VARCHAR(50), value INTEGER) RETURNS int
--     DETERMINISTIC
-- BEGIN
--     UPDATE sequence
--     SET current_value = value
--     WHERE seqid = seq_id;
--     RETURN currval(seq_id);
-- END
-- workbench 8.0版本下使用的sql语句 
DELIMITER //
CREATE DEFINER=`root`@`%` FUNCTION `setval`(seq_id VARCHAR(50), value INTEGER) RETURNS int
    DETERMINISTIC
BEGIN
    UPDATE sequence
    SET current_value = value
    WHERE seqid = seq_id;
    RETURN currval(seq_id);
END //
DELIMITER ;