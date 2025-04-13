use prod_KNStudent;
DROP VIEW IF EXISTS v_info_lesson_sum_fee_pay_over;
CREATE VIEW v_info_lesson_sum_fee_pay_over AS
SELECT 
	pay.lsn_pay_id,
    fee.lsn_fee_id,
    fee.stu_id,
    fee.stu_name,
    fee.subject_id,
    fee.subject_name,
    fee.subject_sub_id,
    fee.subject_sub_name,
    fee.subject_price,
    fee.pay_style,
    SUM(fee.lsn_count) AS lsn_count,
    SUM(fee.lsn_fee) AS lsn_fee, -- 应支付
    SUM(pay.lsn_pay) AS lsn_pay, -- 已支付
    pay.pay_date,
    pay.bank_id,
    fee.lsn_month,
    fee.lsn_month as pay_month,
    fee.lesson_type
FROM 
    (
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
			    lesson_type,
				CASE 
					WHEN lesson_type = 1 THEN subject_price * 4
					ELSE sum(lsn_fee)
				END AS lsn_fee,
			    lsn_count,
				lsn_month
			FROM(
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
					lesson_type,
			        sum(lsn_count) as lsn_count,
					sum(lsn_fee) as lsn_fee,
					lsn_month
				FROM v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
			    where own_flg = 1
				GROUP BY lsn_fee_id,stu_id,stu_name,		
			    subject_id,
			        subject_name,
			        subject_sub_id,
			        subject_sub_name,lsn_month,subject_price,pay_style,lesson_type
			    )aa
			GROUP BY lsn_fee_id,stu_id,stu_name,		
			    subject_id,
			        subject_name,
			        subject_sub_id,
			        subject_sub_name,lsn_month,subject_price,pay_style,lesson_type,lsn_count
    ) fee
    inner join
    t_info_lesson_pay pay
On
	fee.lsn_fee_id = pay.lsn_fee_id
GROUP BY 
	pay.lsn_pay_id,
    fee.lsn_fee_id,
    fee.stu_id,
    fee.stu_name,
    fee.subject_id,
    fee.subject_name,
    fee.subject_sub_id,
    fee.subject_sub_name,
    fee.subject_price,
    fee.pay_style,
    fee.lsn_month,
    pay.pay_date,
    fee.lesson_type
    ;