DROP VIEW IF EXISTS v_earliest_fixed_week_info;
CREATE VIEW v_earliest_fixed_week_info AS
SELECT 
    t1.stu_id AS stu_id,
    t1.subject_id AS subject_id,
    t1.fixed_week AS fixed_week,
    t1.fixed_hour AS fixed_hour,
    t1.fixed_minute AS fixed_minute
FROM
    (t_info_fixedlesson t1
    JOIN 
    (SELECT 
			stu_id AS stu_id,
            subject_id AS subject_id,
            MIN((CASE
                WHEN (fixed_week = 'Mon') THEN 1
                WHEN (fixed_week = 'Tue') THEN 2
                WHEN (fixed_week = 'Wed') THEN 3
                WHEN (fixed_week = 'Thu') THEN 4
                WHEN (fixed_week = 'Fri') THEN 5
                WHEN (fixed_week = 'Sat') THEN 6
                WHEN (fixed_week = 'Sun') THEN 7
            END)) AS min_day_num
    FROM
        t_info_fixedlesson
    WHERE
        subject_id IS NOT NULL
    GROUP BY stu_id , subject_id
    ) t2 
    ON t1.stu_id = t2.stu_id AND t1.subject_id = t2.subject_id)
WHERE
    (CASE
        WHEN (t1.fixed_week = 'Mon') THEN 1
        WHEN (t1.fixed_week = 'Tue') THEN 2
        WHEN (t1.fixed_week = 'Wed') THEN 3
        WHEN (t1.fixed_week = 'Thu') THEN 4
        WHEN (t1.fixed_week = 'Fri') THEN 5
        WHEN (t1.fixed_week = 'Sat') THEN 6
        WHEN (t1.fixed_week = 'Sun') THEN 7
    END) = t2.min_day_num
ORDER BY t1.stu_id , t1.subject_id;