
use prod_KNStudent;
DROP VIEW IF EXISTS v_sum_lsn_fee_for_fee_connect_lsn;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW v_sum_lsn_fee_for_fee_connect_lsn AS
/* 这是按照学生实际上的课产生的实际的学费
    SELECT 
        stu_id AS stu_id,
        stu_name AS stu_name,
        lsn_fee_id AS lsn_fee_id,
        subject_price AS subject_price,
        lesson_type AS lesson_type,
        SUM(lsn_fee) AS lsn_fee,
        lsn_month AS lsn_month
    FROM
        v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
    GROUP BY stu_id ,
             stu_name , 
             lsn_month , 
             lsn_fee_id , 
             subject_price , 
             lesson_type;
*/ 
/* 这是按照学生应缴纳的学费 */
    SELECT 
        stu_id AS stu_id,
        stu_name AS stu_name,
        -- lsn_fee_id AS lsn_fee_id,
        subject_price AS subject_price,
        lesson_type AS lesson_type,
        case when (pay_style = 1 and lesson_type = 1) then subject_price * 4
			 else SUM(lsn_fee) 
		end AS lsn_fee,
        lsn_month AS lsn_month
    FROM
        v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
    GROUP BY stu_id ,
             stu_name , 
             lsn_month , 
           --   lsn_fee_id , 
             subject_price , 
             lesson_type,
             pay_style;
