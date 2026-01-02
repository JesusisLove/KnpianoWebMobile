# Bug调查报告：12月份月计划课费已结算记录无删除线问题

## 问题描述
12月份的月计划课费中，已结算的课费应该带删除线显示，但实际显示时没有删除线。

## 调查路径
Flutter前端 → Spring Boot中间层 → MyBatis → MySQL数据库视图

---

## 第一层：Flutter前端层

### 文件位置
`01FlutterApps/front_dart_flutter/lib/02LsnFeeMngmnt/kn02F002LsnFeeDetail.dart`

### 删除线逻辑
**代码位置：第467-469行（科目名称）**
```dart
decoration: item.ownFlg == 1
    ? TextDecoration.lineThrough
    : TextDecoration.none,
```

**代码位置：第506-508行（课时和课费）**
```dart
decoration: item.ownFlg == 1
    ? TextDecoration.lineThrough
    : TextDecoration.none,
```

### 结论
✅ **前端逻辑正确**：当`ownFlg == 1`时显示删除线，当`ownFlg != 1`时不显示删除线。

---

## 第二层：Flutter Bean解析层

### 文件位置
`01FlutterApps/front_dart_flutter/lib/02LsnFeeMngmnt/Kn02F002FeeBean.dart`

### 数据解析逻辑
**代码位置：第98行**
```dart
ownFlg: json['ownFlg'] ?? 0,
```

### 结论
✅ **Bean解析正确**：直接从JSON获取`ownFlg`字段，如果为null则默认为0。

---

## 第三层：Spring Boot Controller层

### 文件位置
`01FlutterApps/middle_layer_springboot/knpiano_java/src/main/java/com/liu/springboot04web/controller_mobile/Kn02F002FeeController4Mobile.java`

### API端点
**方法：** `getStuFeeDetaillist`
**路径：** `/mb_kn_lsn_fee_by_year/{stuId}/{selectedYear}`
**代码位置：第43-50行**
```java
public ResponseEntity<List<Kn02F004FeePaid4MobileBean>> getStuFeeDetaillist(
    @PathVariable("stuId") String stuId,
    @PathVariable("selectedYear") Integer year) {
    List<Kn02F004FeePaid4MobileBean> list = knLsnFee001Dao.getStuFeeDetaillist(stuId, Integer.toString(year));
    return ResponseEntity.ok(list);
}
```

### 结论
✅ **Controller层正确**：直接调用DAO层方法，无数据处理。

---

## 第四层：Spring Boot DAO层

### 文件位置
`01FlutterApps/middle_layer_springboot/knpiano_java/src/main/java/com/liu/springboot04web/dao/Kn02F002FeeDao.java`

### 方法逻辑
**代码位置：第126-128行**
```java
public List<Kn02F004FeePaid4MobileBean> getStuFeeDetaillist(String stuId, String yearMonth) {
    List<Kn02F004FeePaid4MobileBean> list = knLsnFee001Mapper.getStuFeeListByYearmonth(stuId, yearMonth);
    return list;
}
```

### 结论
✅ **DAO层正确**：直接调用Mapper方法，无数据处理。

---

## 第五层：MyBatis Mapper层

### 文件位置
`01FlutterApps/middle_layer_springboot/knpiano_java/src/main/resources/mybatis/mapper/Kn02F002FeeMapper.xml`

### SQL查询结构
**方法：** `getStuFeeListByYearmonth`
**代码位置：第127-221行**

该查询使用三个UNION ALL组合三类数据：

#### 第一个查询（未支付普通课费）
**代码：第128-155行**
```xml
select stu_id, stu_name, lsn_pay_id, lsn_fee_id, ..., own_flg, ...
from v_info_lesson_sum_fee_unpaid_yet
where stu_id = #{stuId} ...
```
- ✅ `own_flg`从视图直接获取

#### 第二个查询（空月课费 - 本次新增功能）
**代码：第157-185行**
```xml
select stu_id, stu_name, lsn_pay_id, lsn_fee_id, ..., own_flg, ...
from v_info_tmp_lesson_after_43_month_fee_unpaid_yet
where stu_id = #{stuId} ...
```
- ✅ `own_flg`从视图直接获取（第173行）
- ⚠️ **视图名称含"unpaid_yet"但查询未过滤own_flg**

#### 第三个查询（已支付普通课费）
**代码：第187-219行**
```xml
select paid.stu_id, paid.stu_name, paid.lsn_pay_id, paid.lsn_fee_id, ...,
       1 as own_flg,  -- ⚠️ 硬编码为1
       lfap.advc_flg, bnk.bank_name
from v_info_lesson_sum_fee_pay_over paid
...
where stu_id = #{stuId} ...
```
- ✅ `own_flg`硬编码为1（已支付）
- ❌ **该视图不包含临时课程表数据**

### 结论
⚠️ **发现问题点**：
1. 第二个查询使用的视图`v_info_tmp_lesson_after_43_month_fee_unpaid_yet`没有过滤`own_flg=0`
2. 第三个查询使用的视图`v_info_lesson_sum_fee_pay_over`不包含临时课程表数据

---

## 第六层：MySQL视图层 - 空月课费视图

### 文件位置
`02DBTableGenerateTool/MySQL_KNStudent/Views/v_info_tmp_lesson_after_43_month_fee_unpaid_yet.sql`

### 视图定义
**代码：第15-43行**
```sql
CREATE VIEW v_info_tmp_lesson_after_43_month_fee_unpaid_yet AS
SELECT
    '' as lsn_pay_id,
    fee.lsn_fee_id,
    tmp.stu_id,
    tmp.stu_name,
    ...
    fee.own_flg as own_flg  -- ✅ 从t_info_lesson_fee表获取真实值
FROM
    v_info_lesson_tmp tmp
INNER JOIN
    t_info_lesson_fee fee
ON tmp.lsn_tmp_id = fee.lesson_id
-- ❌ 缺少WHERE own_flg = 0的过滤条件
```

### 问题分析
🔴 **严重问题**：
1. **视图名称含义**：`unpaid_yet`（未支付）
2. **视图注释说明**：第7-9行明确说明"这些未支付的按月支付课费信息"
3. **实际查询逻辑**：没有`WHERE own_flg = 0`过滤条件
4. **结果**：视图返回所有空月课费，包括已支付和未支付的记录

---

## 第七层：MySQL视图层 - 已支付课费视图

### 文件位置
`02DBTableGenerateTool/MySQL_KNStudent/prod_KNStudent.sql`（第1290行）

### 视图定义
**视图：** `v_info_lesson_sum_fee_pay_over`
**代码：第1316-1369行**
```sql
FROM
    (
        SELECT ...
        FROM (
            SELECT ...
            FROM v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect
            WHERE own_flg = 1  -- 只查询已支付
            ...
        ) aa
        ...
    ) fee
    INNER JOIN t_info_lesson_pay pay
    ON fee.lsn_fee_id = pay.lsn_fee_id
```

该视图依赖于`v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect`

### 追溯依赖视图
**视图：** `v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect`（第1038行）
```sql
FROM
    ((v_info_lesson_fee_and_extraToScheDataCorrect fee
    JOIN v_info_lesson_and_extraToScheDataCorrect lsn  -- ❌ 关键问题
    ...
```

**视图：** `v_info_lesson_and_extraToScheDataCorrect`（第817行）
```sql
FROM
    (
        SELECT ...
        FROM t_info_lesson lsn  -- ❌ 只查询正式课程表
        WHERE extra_to_dur_date IS NULL
        UNION ALL
        SELECT ...
        FROM t_info_lesson lsn  -- ❌ 只查询正式课程表
        INNER JOIN t_info_lesson_extra_to_sche extr
        ...
    ) lsn
```

### 问题分析
🔴 **根本原因**：
- 视图`v_info_lesson_and_extraToScheDataCorrect`只查询`t_info_lesson`表（正式课程表）
- **完全不包含`t_info_lesson_tmp`表**（临时课程表）
- 导致已支付的空月课费无法出现在"已支付课费"列表中

---

## 综合分析

### 数据流向问题

#### 场景1：空月课费未支付（own_flg=0）
1. 记录存在于`t_info_lesson_tmp`和`t_info_lesson_fee`（own_flg=0）
2. Mapper第二个UNION ALL查询从`v_info_tmp_lesson_after_43_month_fee_unpaid_yet`获取
3. 返回`own_flg=0`给Flutter
4. ✅ Flutter正确显示无删除线

#### 场景2：空月课费已支付（own_flg=1）
1. 记录存在于`t_info_lesson_tmp`和`t_info_lesson_fee`（own_flg=1）
2. Mapper第二个UNION ALL查询从`v_info_tmp_lesson_after_43_month_fee_unpaid_yet`获取
3. 返回`own_flg=1`给Flutter
4. ✅ **理论上**Flutter应该显示删除线

#### ⚠️ 但为什么没有删除线？

可能的原因：
1. **视图过滤问题**：Mapper.xml或视图中可能有WHERE条件过滤了`own_flg=1`的记录
2. **数据库数据问题**：`t_info_lesson_fee`表中的`own_flg`字段未正确更新为1
3. **并发查询冲突**：如果同一个空月课费记录同时满足多个UNION ALL条件，可能被后面的查询结果覆盖

---

## 问题点总结

### 🔴 严重问题

1. **视图名称与实际功能不符**
   - 视图：`v_info_tmp_lesson_after_43_month_fee_unpaid_yet`
   - 问题：名称和注释说明是"未支付"，但查询逻辑未过滤`own_flg`
   - 影响：返回所有空月课费（包括已支付和未支付）

2. **已支付课费视图不包含临时课程**
   - 视图：`v_info_lesson_sum_fee_pay_over`（通过依赖链）
   - 问题：只查询`t_info_lesson`表，不包含`t_info_lesson_tmp`表
   - 影响：已支付的空月课费不会出现在已支付列表（第三个UNION ALL查询）

### ⚠️ 设计缺陷

3. **数据分散在两个UNION查询中**
   - 第二个查询：包含所有空月课费（未支付+已支付）
   - 第三个查询：包含所有普通课费已支付记录
   - 问题：空月课费的已支付和未支付都在同一个视图中，但普通课费分散在两个视图

---

## 建议修复方案

### 方案1：修改视图添加WHERE过滤（推荐）

**修改文件：** `v_info_tmp_lesson_after_43_month_fee_unpaid_yet.sql`

在视图定义末尾添加WHERE条件：
```sql
FROM
    v_info_lesson_tmp tmp
INNER JOIN
    t_info_lesson_fee fee
ON tmp.lsn_tmp_id = fee.lesson_id
WHERE fee.own_flg = 0;  -- ✅ 添加此行
```

**优点：**
- 符合视图名称和注释的语义
- 最小改动
- 不影响已支付记录（它们应该在第三个UNION ALL中）

**缺点：**
- 已支付的空月课费不会出现在任何查询中（因为第三个UNION不包含临时课程表）
- 需要同步修改`v_info_lesson_sum_fee_pay_over`视图链

### 方案2：创建空月课费已支付视图并修改Mapper（完整方案）

#### 步骤1：创建新视图
```sql
CREATE VIEW v_info_tmp_lesson_after_43_month_fee_paid AS
SELECT
    pay.lsn_pay_id,
    fee.lsn_fee_id,
    tmp.stu_id,
    tmp.stu_name,
    tmp.nik_name,
    tmp.subject_id,
    tmp.subject_name,
    tmp.subject_sub_id,
    tmp.subject_sub_name,
    fee.lsn_fee as subject_price,
    1 as pay_style,
    0 AS lsn_count,
    fee.lsn_fee * 4 as lsn_fee,
    pay.pay_date,
    1 as lesson_type,
    left(tmp.schedual_date,7) as lsn_month,
    pay.bank_id
FROM
    v_info_lesson_tmp tmp
INNER JOIN t_info_lesson_fee fee
    ON tmp.lsn_tmp_id = fee.lesson_id
INNER JOIN t_info_lesson_pay pay
    ON fee.lsn_fee_id = pay.lsn_fee_id
WHERE fee.own_flg = 1;
```

#### 步骤2：修改Mapper.xml
在第三个UNION ALL查询中添加临时课程的已支付记录：
```xml
union all
select   stu_id, stu_name, lsn_pay_id, lsn_fee_id, ...,
         1 as own_flg,  -- 已支付
         1 as advc_flg,
         '' as bank_name
    from v_info_tmp_lesson_after_43_month_fee_paid
    <where>
        stu_id = #{stuId}
        <if test="yearMonth != null and yearMonth.length() == 4">
            AND left(lsn_month, 4) = #{yearMonth}
        </if>
        <if test="yearMonth != null and yearMonth.length() == 7">
            AND left(lsn_month, 7) = #{yearMonth}
        </if>
    </where>
```

#### 步骤3：修改原视图添加过滤
```sql
-- 修改 v_info_tmp_lesson_after_43_month_fee_unpaid_yet
WHERE fee.own_flg = 0;
```

**优点：**
- 架构清晰：未支付在第二个查询，已支付在新增的第四个查询
- 与普通课费的处理逻辑一致
- 完全隔离已支付和未支付数据

**缺点：**
- 需要创建新视图
- 需要修改Mapper.xml
- 改动较大

### 方案3：检查数据库数据（优先排查）

在修改代码前，先确认问题是否出在数据层：

```sql
-- 查询12月份的空月课费记录
SELECT
    tmp.lsn_tmp_id,
    tmp.stu_id,
    tmp.stu_name,
    tmp.schedual_date,
    fee.lsn_fee_id,
    fee.own_flg,  -- 检查此字段值
    pay.lsn_pay_id,
    pay.pay_date
FROM t_info_lesson_tmp tmp
INNER JOIN t_info_lesson_fee fee ON tmp.lsn_tmp_id = fee.lesson_id
LEFT JOIN t_info_lesson_pay pay ON fee.lsn_fee_id = pay.lsn_fee_id
WHERE tmp.stu_id = '{用户报告的学生ID}'
  AND YEAR(tmp.schedual_date) = 2025
  AND MONTH(tmp.schedual_date) = 12
ORDER BY tmp.schedual_date;
```

检查结果：
- 如果`own_flg=1`但`lsn_pay_id`为NULL：数据不一致
- 如果`own_flg=0`但`lsn_pay_id`有值：支付后未更新own_flg
- 如果`own_flg=1`且`lsn_pay_id`有值：前端逻辑问题

---

## 建议执行顺序

1. ✅ **立即执行**：方案3（检查数据库数据）
   - 确认问题是代码还是数据

2. 📋 **短期修复**：方案1（添加WHERE过滤）
   - 如果数据正确但代码有问题，使用此方案快速修复

3. 🏗️ **长期优化**：方案2（完整架构调整）
   - 确保空月课费和普通课费的处理逻辑完全一致

---

## 需要用户提供的信息

1. 具体是哪个学生的12月份课费有问题？（需要stu_id）
2. 该课费是否已经执行过支付操作？
3. 能否提供bug.png截图的访问权限？（当前无法读取Desktop文件）

---

**调查人员：** Claude Code
**调查日期：** 2025-12-24
**问题级别：** 高（影响用户体验）
**预计修复时间：** 方案1约30分钟，方案2约2小时
