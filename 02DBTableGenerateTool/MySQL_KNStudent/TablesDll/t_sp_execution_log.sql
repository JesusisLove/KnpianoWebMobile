-- 建立调用课费预支付存储过程日志表
CREATE TABLE t_sp_execution_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    procedure_name VARCHAR(100),
    procedure_alias_name VARCHAR(100),
    step_name VARCHAR(100),
    result VARCHAR(255),
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);