-- ==========================================
-- 查询：在指定月份首次达到43节课的学生
-- 用途：用于Batch系统，自动为达到43节课的学生生成剩余月份的临时课程
-- 创建日期: 2025-12-22
-- ==========================================

-- 使用说明：
-- 1. 修改最后的 WHERE 条件中的 lsn_month 参数来查询不同月份
-- 2. 例如查询10月：lsn_month = '2025-10'
-- 3. 例如查询11月：lsn_month = '2025-11'

WITH monthly_summary AS (
    -- 第一步：计算每个学生每月的课程数
    SELECT
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        lsn_month,
        SUM(lsn_count) AS monthly_count
    FROM v_info_lsn_statistics_by_stuid
    WHERE lesson_type = 1  -- 只统计月计划课程
      AND lsn_month BETWEEN DATE_FORMAT(CURDATE(), '%Y-01')
                        AND DATE_FORMAT(CURDATE(), '%Y-12')
    GROUP BY stu_id, stu_name, subject_id, subject_name, lsn_month
),
with_cumulative AS (
    -- 第二步：计算累计课程数
    SELECT
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        lsn_month,
        monthly_count,
        SUM(monthly_count) OVER (
            PARTITION BY stu_id, subject_id
            ORDER BY lsn_month
        ) AS cumulative_count
    FROM monthly_summary
),
monthly_cumulative AS (
    -- 第三步：使用LAG获取上月累计数
    SELECT
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        lsn_month,
        monthly_count,
        cumulative_count,
        LAG(cumulative_count, 1, 0) OVER (
            PARTITION BY stu_id, subject_id
            ORDER BY lsn_month
        ) AS prev_cumulative_count
    FROM with_cumulative
)
SELECT
    stu_id,
    stu_name,
    subject_id,
    subject_name,
    lsn_month AS achieved_month,
    monthly_count AS '当月上课数',
    cumulative_count AS '累计课程数',
    prev_cumulative_count AS '上月累计数'
FROM monthly_cumulative
WHERE cumulative_count >= 43           -- 当月累计达到或超过43节
  AND prev_cumulative_count < 43       -- 上月累计还没达到43节
  AND lsn_month = DATE_FORMAT(CURDATE(), '%Y-%m')  -- 查询当前月份
  -- 如果要查询特定月份，修改上面一行，例如：
  -- AND lsn_month = '2025-10'  -- 查询2025年10月
  -- AND lsn_month = '2025-11'  -- 查询2025年11月
ORDER BY stu_id, subject_id;

-- ==========================================
-- 测试查询示例
-- ==========================================

-- 示例1：查询2025年10月份达到43节的学生
/*
WITH monthly_summary AS (
    SELECT stu_id, stu_name, subject_id, subject_name, lsn_month,
           SUM(lsn_count) AS monthly_count
    FROM v_info_lsn_statistics_by_stuid
    WHERE lesson_type = 1 AND lsn_month BETWEEN '2025-01' AND '2025-12'
    GROUP BY stu_id, stu_name, subject_id, subject_name, lsn_month
),
with_cumulative AS (
    SELECT stu_id, stu_name, subject_id, subject_name, lsn_month, monthly_count,
           SUM(monthly_count) OVER (PARTITION BY stu_id, subject_id ORDER BY lsn_month) AS cumulative_count
    FROM monthly_summary
),
monthly_cumulative AS (
    SELECT stu_id, stu_name, subject_id, subject_name, lsn_month, monthly_count, cumulative_count,
           LAG(cumulative_count, 1, 0) OVER (PARTITION BY stu_id, subject_id ORDER BY lsn_month) AS prev_cumulative_count
    FROM with_cumulative
)
SELECT stu_id, stu_name, subject_id, subject_name, lsn_month AS achieved_month,
       monthly_count AS '当月上课数', cumulative_count AS '累计课程数', prev_cumulative_count AS '上月累计数'
FROM monthly_cumulative
WHERE cumulative_count >= 43 AND prev_cumulative_count < 43 AND lsn_month = '2025-10'
ORDER BY stu_id, subject_id;
*/

-- 示例2：查询2025年11月份达到43节的学生
/*
-- 只需修改最后一行的 lsn_month = '2025-11'
*/

-- ==========================================
-- 用于Batch系统的调用示例
-- ==========================================

-- 假设在Batch系统中，可以这样使用：
-- 1. 查询当前月份达到43节的学生
-- 2. 遍历查询结果
-- 3. 对每个学生调用存储过程 sp_insert_tmp_lesson_info
--    为剩余月份生成临时课程和课费

-- 伪代码示例：
/*
DECLARE done INT DEFAULT FALSE;
DECLARE v_stu_id VARCHAR(32);
DECLARE v_subject_id VARCHAR(32);
DECLARE v_current_month VARCHAR(7);
DECLARE v_remaining_months INT;

-- 获取当前月份
SET v_current_month = DATE_FORMAT(CURDATE(), '%Y-%m');

-- 游标定义（查询达到43节的学生）
DECLARE cur CURSOR FOR
    SELECT stu_id, subject_id FROM monthly_cumulative
    WHERE cumulative_count >= 43 AND prev_cumulative_count < 43
      AND lsn_month = v_current_month;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur;

read_loop: LOOP
    FETCH cur INTO v_stu_id, v_subject_id;
    IF done THEN
        LEAVE read_loop;
    END IF;

    -- 计算剩余月份
    SET v_remaining_months = 12 - MONTH(CURDATE());

    -- 为剩余每个月生成临时课程
    WHILE v_remaining_months > 0 DO
        CALL sp_insert_tmp_lesson_info(
            v_stu_id,
            v_subject_id,
            DATE_FORMAT(DATE_ADD(CURDATE(), INTERVAL v_remaining_months MONTH), '%Y-%m-01')
        );
        SET v_remaining_months = v_remaining_months - 1;
    END WHILE;

END LOOP;

CLOSE cur;
*/
