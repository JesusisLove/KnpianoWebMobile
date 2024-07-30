-- 建立调用课费预支付存储过程日志表
-- CREATE TABLE sp_execution_log (
--     id INT AUTO_INCREMENT PRIMARY KEY,
--     procedure_name VARCHAR(100),
--     step_name VARCHAR(100),
--     result VARCHAR(255),
--     execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
-- );

-- 调试调用执行课费预支付存储过程
CALL sp_execute_advc_lsn_fee_pay(
    'kn-stu-3',           -- stu_id
    'kn-sub-6',           -- subject_id
    'kn-sub-eda-27',      -- subject_sub_id
    1,                    -- lesson_type
    0,                    -- schedual_type
    60,                   -- minutes_per_lsn
    100.00,               -- subject_price
    '2024-08-30 09:00:00', -- schedual_datetime (添加具体时间)
    'kn-bnk-1',           -- bank_id
    'kn-lsn-',            -- lsn_seq_code
    'kn-fee-',            -- fee_seq_code
    'kn-pay-',            -- pay_seq_code
    @result               -- p_result (OUT parameter)
);

-- 检查结果
SELECT @result AS procedure_result;
SELECT * FROM KNStudent.sp_execution_log;

-- select CONCAT('kn-lsn-', nextval('kn-lsn-')) as lesson_id
-- 	  ,CONCAT('kn-fee-', nextval('kn-fee-')) as lsn_fee_id
--       ,CONCAT('kn-pay-', nextval('kn-pay-')) as lsn_pay_id
-- from dual;

/*
1 row(s) affected, 1 warning(s): 1292 Incorrect date value: '2024-08-30 11:30' for column 'schedual_date' at row 1
*/
