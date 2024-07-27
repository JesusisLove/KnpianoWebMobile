-- CREATE DEFINER=`root`@`localhost` FUNCTION `currval`(seq_id VARCHAR(50)) RETURNS int
--     DETERMINISTIC
-- BEGIN
--     DECLARE value INTEGER;
--     SET value = 0;
--     SELECT current_value INTO value
--         FROM sequence
--         WHERE seqid = seq_id;
--     RETURN value;
-- END

-- workbench 8.0版本下使用的sql语句 
DELIMITER //

CREATE DEFINER=`root`@`localhost` FUNCTION `currval`(seq_id VARCHAR(50)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE value INTEGER DEFAULT 0;
    SELECT current_value INTO value
    FROM sequence
    WHERE seqid = seq_id;
    RETURN value;
END //

DELIMITER ;