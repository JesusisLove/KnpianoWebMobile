-- CREATE DEFINER=`root`@`%` FUNCTION `nextval`(seq_id VARCHAR(50)) RETURNS int
--     DETERMINISTIC
-- BEGIN
--     UPDATE sequence
--     SET current_value = current_value + increment
--     WHERE seqid = seq_id;
--     RETURN currval(seq_id);
-- END

-- workbench 8.0版本下使用的sql语句 
DELIMITER //
CREATE DEFINER=`root`@`%` FUNCTION `nextval`(seq_id VARCHAR(50)) RETURNS int
    DETERMINISTIC
BEGIN
    UPDATE sequence
    SET current_value = current_value + increment
    WHERE seqid = seq_id;
    RETURN currval(seq_id);
END