-- 邮件配置表
-- use prod_KNPiano

CREATE TABLE t_batch_mail_config (
    job_id VARCHAR(20) NOT NULL COMMENT '作业ID',
    email_from VARCHAR(100) NOT NULL COMMENT '发送方邮箱',
    mail_to_devloper VARCHAR(500) COMMENT '开发者邮箱(多个邮箱用逗号分隔)',
    email_to_user VARCHAR(500) COMMENT '用户邮箱(多个邮箱用逗号分隔)',
    mail_content_for_user TEXT COMMENT '给用户的邮件内容',
    PRIMARY KEY (job_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='批处理邮件配置表';