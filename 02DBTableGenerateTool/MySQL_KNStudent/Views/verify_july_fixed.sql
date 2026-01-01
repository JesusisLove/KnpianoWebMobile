-- ============================================================
-- 调查应支付总额≠已支付总额+未支付总额的问题（1月，2月份和7月份）
-- 调查清楚是数据的问题之后，利用下面的SQL语句为Batch系统追加了一个学费数据监视的一个Batch处理模块 KNDB2020
-- 验证2025年全年数据
-- ============================================================

USE KNStudent;

-- ============================================================
-- 1. 验证所有月份（2025年全年）
-- ============================================================

SELECT '=== 验证所有月份（2025年全年） ===' as verification;

SELECT
    lsn_month,
    should_pay_lsn_fee AS 应收,
    has_paid_lsn_fee AS 已支付,
    unpaid_lsn_fee AS 未支付,
    (has_paid_lsn_fee + unpaid_lsn_fee) AS 已支付加未支付,
    (should_pay_lsn_fee - (has_paid_lsn_fee + unpaid_lsn_fee)) AS 差额,
    CASE
        WHEN ABS(should_pay_lsn_fee - (has_paid_lsn_fee + unpaid_lsn_fee)) < 0.01
        THEN '✓'
        ELSE '✗'
    END as 验证
FROM v_total_lsnfee_with_paid_unpaid_every_month
WHERE lsn_month LIKE '2025-%'
ORDER BY lsn_month;

-- ============================================================
-- 2. 汇总验证结果
-- ============================================================

SELECT '=== 汇总验证结果 ===' as summary;

SELECT
    COUNT(*) as 总月份数,
    SUM(CASE WHEN ABS(should_pay_lsn_fee - (has_paid_lsn_fee + unpaid_lsn_fee)) < 0.01 THEN 1 ELSE 0 END) as 正确月份数,
    SUM(CASE WHEN ABS(should_pay_lsn_fee - (has_paid_lsn_fee + unpaid_lsn_fee)) >= 0.01 THEN 1 ELSE 0 END) as 错误月份数,
    CASE
        WHEN SUM(CASE WHEN ABS(should_pay_lsn_fee - (has_paid_lsn_fee + unpaid_lsn_fee)) >= 0.01 THEN 1 ELSE 0 END) = 0
        THEN '✓ 全部正确！'
        ELSE '✗ 仍有错误月份'
    END as 最终结果
FROM v_total_lsnfee_with_paid_unpaid_every_month
WHERE lsn_month LIKE '2025-%';
