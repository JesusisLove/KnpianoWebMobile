use KNStudent;
-- 前提条件，加课都已经签到完了，找出那些已经结算和还未结算的加课信息
-- 已经结算的加课费
DROP VIEW IF EXISTS v_info_all_extra_lsns;
CREATE VIEW v_info_all_extra_lsns AS 
SELECT 
	-- pay.lsn_pay_id, 
    -- fee.lsn_fee_id, 
    lsn.lesson_id,
    lsn.stu_id,
    lsn.subject_id,
    lsn.subject_sub_id,
    lsn.class_duration,
    lsn.lesson_type,
    lsn.schedual_type,
    lsn.schedual_date,
    lsn.lsn_adjusted_date,
    lsn.extra_to_dur_date,
    lsn.scanqr_date,
    1 as pay_flg 
FROM 
	t_info_lesson lsn
	inner join 
	t_info_lesson_fee fee
	on lsn.lesson_id = fee.lesson_id
	inner join
	t_info_lesson_pay pay
	on fee.lsn_fee_id = pay.lsn_fee_id
	where lsn.scanqr_date is not null 
	and lsn.lesson_type = 2 -- 加课课程标识
union all
-- 已经结算的加课费
SELECT 
    main.lesson_id,
    main.stu_id,
    main.subject_id,
    main.subject_sub_id,
    main.class_duration,
    main.lesson_type,
    main.schedual_type,
    main.schedual_date,
    main.lsn_adjusted_date,
    main.extra_to_dur_date,
    main.scanqr_date,
    0 as pay_flg 
FROM t_info_lesson main
WHERE main.scanqr_date IS NOT NULL 
  AND main.lesson_type = 2
  AND NOT EXISTS (
    SELECT 1 
    FROM t_info_lesson lsn
    INNER JOIN t_info_lesson_fee fee ON lsn.lesson_id = fee.lesson_id
    INNER JOIN t_info_lesson_pay pay ON fee.lsn_fee_id = pay.lsn_fee_id
    WHERE lsn.lesson_id = main.lesson_id
  );
