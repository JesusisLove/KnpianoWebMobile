use prod_KNStudent;
DROP VIEW IF EXISTS v_info_lesson_sum_fee_unpaid_yet;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = root@localhost 
    SQL SECURITY DEFINER
VIEW v_info_lesson_sum_fee_unpaid_yet AS
    SELECT
    '' as lsn_pay_id,
    newtmptbl.lsn_fee_id,    -- 明确指定来源
    newtmptbl.stu_id,
    newtmptbl.stu_name,
    newtmptbl.subject_id,
    newtmptbl.subject_name,
    newtmptbl.subject_sub_id,
    newtmptbl.subject_sub_name,
    newtmptbl.subject_price,
    newtmptbl.pay_style,
    SUM(newtmptbl.lsn_count) AS lsn_count,
    sum(case when newtmptbl.lesson_type = 1 then newtmptbl.subject_price * 4
           else newtmptbl.lsn_fee end ) as lsn_fee,
    NULL as pay_date,
    newtmptbl.lesson_type,
    newtmptbl.lsn_month,
    newtmptbl.own_flg 
from (
    SELECT 
        lsn_fee_id,
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
        subject_price,
        pay_style,
        SUM(lsn_count) AS lsn_count,
        SUM(lsn_fee) as lsn_fee,
        lesson_type,
        lsn_month,
        own_flg 
    FROM 
        v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
    WHERE 
        own_flg = 0
        AND del_flg = 0
    GROUP BY 
        lsn_fee_id,
        stu_id,
        stu_name,
        subject_id,
        subject_name,
        subject_sub_id,
        subject_sub_name,
        subject_price,
        pay_style,
        lesson_type,
        lsn_month,
        own_flg
) newtmptbl
GROUP BY 
    newtmptbl.lsn_fee_id,
    newtmptbl.stu_id,
    newtmptbl.stu_name,
    newtmptbl.subject_id,
    newtmptbl.subject_name,
    newtmptbl.subject_sub_id,
    newtmptbl.subject_sub_name,
    newtmptbl.subject_price,
    newtmptbl.pay_style,
    newtmptbl.lesson_type,
    newtmptbl.lsn_month,
    newtmptbl.own_flg;