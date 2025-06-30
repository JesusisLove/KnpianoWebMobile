-- USE prod_KNStudent;
-- DROP VIEW IF EXISTS `v_earliest_fixed_week_info`;
/* 给AI的提示词：
这是t_info_fixedlesson中stu_id是，'kn-stu-3'的结果集，这个条件下的结果集里，
你看kn-sub-20的记录，有2条记录，从fixed_week字段上看有“Fri”和“Thu”，因为Thu比Fri早，所以kn-sub-20的记录中“Thu”的这条记录是我要的记录，同理，
你看kn-sub-22的记录，有2条记录，从fixed_week字段上看有“Tue”和“Wed”，因为Tue比Wed早，所以kn-sub-22的记录中“Tue”的这条记录是我要的记录，同理，
你看kn-sub-6的记录，有3条记录，从fixed_week字段上看有“Mon”和“Tue”和“Thu”，因为这三个星期中“Mon”是最早的，所以kn-sub-6的记录中“Mon”的这条记录是我要的记录，
同样道理，如果换成stu_id是其他的学生编号，也是按照这个要求，在他的当前科目中找出星期最早的那个记录显示出来。
理解了我的要求了吗？请你按照我的要求给我写一个Mysql的Sql语句。
*/
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