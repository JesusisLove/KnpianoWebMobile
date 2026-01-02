# Bug调查报告：未缴纳学费明细页面数据显示错误

## 问题描述
**页面**：未缴纳学费明细（UnpaidFeesPage）
**学生**：Cara Rey Choo
**错误现象**：
- 应支付额：显示75.0（❌ 错误，应该是375）
- 实支付额：显示0.0（❌ 错误，应该是300）
- 未支付额：显示75.0（✅ 正确）

## 数据流追踪

### 1. Flutter前端层
**文件**：`Kn02f005FeeMonthlyUnpaidPage.dart`

**数据显示**（第578-602行）：
```dart
Text(fee.shouldPayLsnFee.toStringAsFixed(1))  // 应支付额
Text(fee.hasPaidLsnFee.toStringAsFixed(1))    // 实支付额
Text(fee.unpaidLsnFee.toStringAsFixed(1))     // 未支付额
```

**Bean解析**（`Kn02f005FeeMonthlyReportBean.dart` 第22-24行）：
```dart
shouldPayLsnFee: json['shouldPayLsnFee']?.toDouble() ?? 0.0,
hasPaidLsnFee: json['hasPaidLsnFee']?.toDouble() ?? 0.0,
unpaidLsnFee: json['unpaidLsnFee']?.toDouble() ?? 0.0,
```

✅ **Flutter层正确**：直接从JSON获取数据，无逻辑处理

---

### 2. Spring Boot中间层
**Controller**：`Kn02f005FeeReportController4Mobile.java` 第30-34行
```java
@GetMapping("/mb_kn02f005_unpaid_details/{yearmonth}")
public ResponseEntity<List<Kn02f005FeeMonthlyReportBean>> unPaidDetailslist(
    @PathVariable("yearmonth") String yearMonth) {
    List<Kn02f005FeeMonthlyReportBean> collection = kn02f005Dao.getUnpaidInfo(yearMonth);
    return ResponseEntity.ok(collection);
}
```

**DAO**：`Kn02f005FeeMonthlyReportDao.java` 第22-25行
```java
public List<Kn02f005FeeMonthlyReportBean> getUnpaidInfo(String yearMonth) {
    List<Kn02f005FeeMonthlyReportBean> list = kn02f005Mapper.getUnpaidInfo(yearMonth);
    return list;
}
```

✅ **Spring Boot层正确**：直接调用Mapper，无数据处理

---

### 3. MyBatis Mapper层
**文件**：`Kn02f005FeeMonthlyReportMapper.xml` 第19-23行
```xml
<select id="getUnpaidInfo" resultType="com.liu.springboot04web.bean.Kn02f005FeeMonthlyReportBean">
    select * from v_total_lsnfee_with_paid_unpaid_every_month_every_student
    where lsn_month = #{yearMonth}
    order by lsn_month, CAST(SUBSTRING_INDEX(stu_id, '-', -1) AS UNSIGNED);
</select>
```

✅ **Mapper层正确**：直接查询视图

---

### 4. MySQL视图层（问题所在）

#### 顶层视图：`v_total_lsnfee_with_paid_unpaid_every_month_every_student`
**位置**：prod_KNStudent.sql 第1639-1684行

**结构**：使用三个UNION ALL聚合数据
```sql
CREATE VIEW v_total_lsnfee_with_paid_unpaid_every_month_every_student AS
SELECT
    feeStatus.stu_id,
    feeStatus.stu_name,
    feeStatus.nik_name,
    feeStatus.lsn_month,
    SUM(feeStatus.should_pay_lsn_fee) AS should_pay_lsn_fee,  -- 应支付
    SUM(feeStatus.has_paid_lsn_fee) AS has_paid_lsn_fee,      -- 已支付
    SUM(feeStatus.unpaid_lsn_fee) AS unpaid_lsn_fee           -- 未支付
FROM (
    -- 第一个查询：应支付金额
    SELECT ...
    FROM v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month T1
    ...
    UNION ALL
    -- 第二个查询：已支付金额
    SELECT ...
    FROM v_sum_haspaid_lsnfee_by_stu_and_month T2
    ...
    UNION ALL
    -- 第三个查询：未支付金额
    SELECT ...
    FROM v_sum_unpaid_lsnfee_by_stu_and_month T3
    ...
) feeStatus
GROUP BY ...;
```

---

#### 底层视图1：`v_sum_lsn_fee_for_fee_connect_lsn_by_stu_month`（应支付金额）
**位置**：prod_KNStudent.sql 第1492-1537行

**关键逻辑**（第1505-1508行）：
```sql
CASE
    WHEN (aa.lesson_type = 1) THEN (aa.subject_price * 4)  -- ✅ 月计划课费正确处理
    ELSE SUM(aa.lsn_fee)                                   -- ✅ 其他课费正确处理
END as lsn_fee,
```

✅ **此视图正确**：月计划课费使用`subject_price * 4`计算

---

#### 底层视图2：`v_sum_haspaid_lsnfee_by_stu_and_month`（已支付金额）
**位置**：prod_KNStudent.sql 第1464-1477行

**当前逻辑**（第1469行）：
```sql
VIEW v_sum_haspaid_lsnfee_by_stu_and_month AS
SELECT
    stu_id,
    stu_name,
    nik_name,
    SUM(lsn_pay) AS lsn_fee,  -- ❌ 问题在这里！只累加lsn_pay
    lsn_month
FROM
    v_info_lesson_sum_fee_pay_over
GROUP BY stu_id, stu_name, nik_name, lsn_month;
```

🔴 **问题根源**：
- 此视图从`v_info_lesson_sum_fee_pay_over`查询已支付课费
- 只累加`lsn_pay`字段（实际支付金额）
- **没有考虑月计划课费应该使用`lsn_fee`字段（包含了`subject_price * 4`的计算）**

---

#### 依赖视图：`v_info_lesson_sum_fee_pay_over`
**位置**：prod_KNStudent.sql 第1290-1384行

**关键字段**（第1308-1310行）：
```sql
SUM(fee.lsn_count) AS lsn_count,
SUM(fee.lsn_fee) AS lsn_fee,   -- ✅ 已正确处理月计划课费（subject_price * 4）
SUM(pay.lsn_pay) AS lsn_pay,   -- 实际支付金额
```

**子查询中的计算**（第1330-1333行）：
```sql
CASE
    WHEN lesson_type = 1 THEN subject_price * 4  -- ✅ 月计划课费
    ELSE SUM(lsn_fee)                            -- ✅ 其他课费
END AS lsn_fee,
```

✅ **此视图的`lsn_fee`字段已正确处理月计划课费**

---

## 问题分析

### 根本原因
`v_sum_haspaid_lsnfee_by_stu_and_month`视图使用`SUM(lsn_pay)`来计算已支付金额，但应该使用`SUM(lsn_fee)`。

### 为什么会出现错误
1. **月计划课费的特殊性**：
   - 一个月一个科目只有1个月计划课费记录
   - 应付金额 = `subject_price * 4`（例如：75 * 4 = 300）
   - `lsn_fee`字段在`v_info_lesson_sum_fee_pay_over`视图中已经正确计算为300
   - 但`lsn_pay`字段可能只记录了单节课的支付金额（75）

2. **数据流**：
   ```
   v_info_lesson_sum_fee_pay_over
   ├─ lsn_fee: 300 (subject_price * 4) ✅
   └─ lsn_pay: 75 (可能只是单节课费) ❌
         ↓
   v_sum_haspaid_lsnfee_by_stu_and_month
   └─ SUM(lsn_pay): 75 ❌ (错误使用)
         ↓
   v_total_lsnfee_with_paid_unpaid_every_month_every_student
   └─ has_paid_lsn_fee: 75 ❌
         ↓
   前端显示
   └─ 实支付额: 75.0 ❌
   ```

3. **Cara Rey Choo的数据**：
   - 月计划课费应付：300（75 * 4）
   - 其他课费应付：75
   - 合计应付：375 ✅
   - 月计划课费已支付：300（但因为使用lsn_pay，只计算了75或0）
   - 显示已支付：0.0 ❌
   - 显示应支付：75 ❌（可能只显示了其他课费，月计划课费没有正确计算）

---

## 修复方案

### 修改文件
`02DBTableGenerateTool/MySQL_KNStudent/Views/v_sum_haspaid_lsnfee_by_stu_and_month.sql`
或
`02DBTableGenerateTool/MySQL_KNStudent/prod_KNStudent.sql` 第1464-1477行

### 修改内容
**修改前**：
```sql
VIEW v_sum_haspaid_lsnfee_by_stu_and_month AS
SELECT
    stu_id,
    stu_name,
    nik_name,
    SUM(lsn_pay) AS lsn_fee,  -- ❌ 错误
    lsn_month
FROM
    v_info_lesson_sum_fee_pay_over
GROUP BY stu_id, stu_name, nik_name, lsn_month;
```

**修改后**：
```sql
VIEW v_sum_haspaid_lsnfee_by_stu_and_month AS
SELECT
    stu_id,
    stu_name,
    nik_name,
    SUM(lsn_fee) AS lsn_fee,  -- ✅ 修改：使用lsn_fee字段
    lsn_month
FROM
    v_info_lesson_sum_fee_pay_over
GROUP BY stu_id, stu_name, nik_name, lsn_month;
```

### 修改理由
- `v_info_lesson_sum_fee_pay_over`视图的`lsn_fee`字段已经正确处理了月计划课费（subject_price * 4）
- 直接使用这个字段即可得到正确的已支付金额

---

## 预期效果

修复后，Cara Rey Choo的数据应该显示为：
- ✅ 应支付额：375.0
- ✅ 实支付额：300.0
- ✅ 未支付额：75.0

---

## 相关Bug修复

这个问题与之前修复的Flutter页面bug类似：
- **Bug2**：学费账单页面（Kn02F003LsnPay）的`calculateHasPaidFee()`方法也有同样问题
- **修复方法**：将`SUM(lsn_pay)`改为对月计划课费使用`subject_price * 4`计算

**教训**：系统中多处使用了相同的错误逻辑，需要全面检查所有涉及已支付金额计算的地方。

---

**调查人员**：Claude Code
**调查日期**：2025-12-24
**问题级别**：高（影响财务统计准确性）
**预计修复时间**：10分钟（修改视图定义并重新部署）
