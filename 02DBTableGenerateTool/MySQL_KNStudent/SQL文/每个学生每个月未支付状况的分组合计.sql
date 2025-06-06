 SELECT * FROM KNStudent.v_info_lesson_sum_fee_unpaid_yet;

-- 每个学生每个月未支付状况的分组合计 v_sum_unpaid_lsnfee_by_stu_and_month
create view v_sum_unpaid_lsnfee_by_stu_and_month as
select stu_id
	  ,stu_name
      ,SUM(lsn_fee) AS lsn_fee
      ,lsn_month
from v_info_lesson_sum_fee_unpaid_yet
group by stu_id
		,stu_name
        ,lsn_month
;
        
-- 使用视图v_sum_unpaid_lsnfee_by_stu_and_month
select * from v_sum_unpaid_lsnfee_by_stu_and_month where substring(lsn_month,1,4)=2024
 and stu_id='kn-stu-3'
order by lsn_month
 		,CAST(SUBSTRING_INDEX(stu_id, '-', -1) AS UNSIGNED);
	

-- 所有在课学生的每个月未支付状况的分组合计 v_sum_upaid_lsnfee_by_month_only
create view v_sum_upaid_lsnfee_by_month_only as
select sum(lsn_fee) as lsn_fee
      ,lsn_month 
from v_sum_unpaid_lsnfee_by_stu_and_month 
group by lsn_month
order by lsn_month
;

select * from v_sum_upaid_lsnfee_by_month_only;

-- 所有在课学生的每个月已支付状况的分组合计 v_sum_haspaid_lsnfee_by_stu_and_month
select * from v_info_lesson_sum_fee_pay_over;
create view v_sum_haspaid_lsnfee_by_stu_and_month as
select stu_id
	  ,stu_name
      ,SUM(lsn_fee) AS lsn_fee
      ,lsn_month
from v_info_lesson_sum_fee_pay_over
group by stu_id
		,stu_name
        ,lsn_month
;

-- //////////////////////////////////////////
-- 所有在课学生按月分组合计 v_sum_total_lsnfee_by_month_only
SELECT 
    SUM(should_pay_lsn_fee) AS should_pay_lsn_fee,
    SUM(has_paid_lsn_fee) AS has_paid_lsn_fee,
    SUM(unpaid_lsn_fee) AS unpaid_lsn_fee,
    lsn_month
FROM (
    SELECT 
        SUM(CASE 
                WHEN lesson_type = 1 THEN subject_price * 4
                ELSE lsn_fee
            END) AS should_pay_lsn_fee,
        0.0 AS has_paid_lsn_fee,
        0.0 AS unpaid_lsn_fee,
        lsn_month
    FROM v_info_lesson_fee_connect_lsn
    GROUP BY lsn_month

    UNION ALL

    SELECT 
        0.0 AS should_pay_lsn_fee,
        SUM(lsn_fee) AS has_paid_lsn_fee,
        0.0 AS unpaid_lsn_fee,
        lsn_month
    FROM v_sum_haspaid_lsnfee_by_stu_and_month
    GROUP BY lsn_month

    UNION ALL

    SELECT 
        0.0 AS should_pay_lsn_fee,
        0.0 AS has_paid_lsn_fee,
        lsn_fee AS unpaid_lsn_fee,
        lsn_month
    FROM v_sum_upaid_lsnfee_by_month_only
) AS lsn_fee_alias -- 别名用于整个派生表的引用
GROUP BY lsn_month;

;