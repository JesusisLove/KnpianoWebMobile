CREATE TABLE t_batch_job_config (
    job_id VARCHAR(20) NOT NULL COMMENT '作业ID',
    bean_name VARCHAR(100) NOT NULL COMMENT 'Bean名称',
    description VARCHAR(255) NOT NULL COMMENT '作业描述', 
    cron_expression VARCHAR(100) NOT NULL COMMENT 'Cron表达式',
    cron_description VARCHAR(255) NOT NULL COMMENT 'Cron描述',
    target_description VARCHAR(255) NOT NULL COMMENT '目标描述',
    batch_enabled BOOLEAN NOT NULL DEFAULT TRUE COMMENT '是否启用批处理',
    PRIMARY KEY (job_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='批处理作业配置表';