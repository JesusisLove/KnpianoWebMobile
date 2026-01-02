# Bug4 调查报告 - 语铭12月月计划课费重复显示问题

## 问题概述

**Bug现象：**
- 学生：语铭 (Lin Yuming, kn-stu-62)
- 月份：2025年12月
- 问题：在手机前端"学费管理 → 课费支付管理 → 语铭的课程费用详细"窗体中，12月的Piano - 月计划课费出现了2条记录：
  - 第1条：0.0节 / $200
  - 第2条：1.0节 / $200
- 预期：应该只显示1条记录：0.0节 / $200 (空课学费)

## 问题根本原因

### 1. 数据流追踪

**前端页面:** [kn02F002LsnFeeDetail.dart](01FlutterApps/front_dart_flutter/lib/02LsnFeeMngmnt/kn02F002LsnFeeDetail.dart#L73-L74)
- API调用: `/liu/mb_kn_lsn_fee_by_year/{stuId}/{selectedYear}`

**后端Controller:** [Kn02F002FeeController4Mobile.java:43-50](01FlutterApps/middle_layer_springboot/knpiano_java/src/main/java/com/liu/springboot04web/controller_mobile/Kn02F002FeeController4Mobile.java#L43-L50)
- 方法: `getStuFeeDetaillist(stuId, year)`

**MyBatis Mapper:** [Kn02F002FeeMapper.xml:127-221](01FlutterApps/middle_layer_springboot/knpiano_java/src/main/resources/mybatis/mapper/Kn02F002FeeMapper.xml#L127-L221)
- SQL ID: `getStuFeeListByYearmonth`
- 使用了3个UNION ALL合并查询

### 2. 重复数据来源分析

**UNION ALL查询结构：**

```sql
-- 第一部分：常规未支付课费 (Lines 128-155)
SELECT ... FROM v_info_lesson_sum_fee_unpaid_yet
WHERE stu_id = #{stuId} ...

UNION ALL

-- 第二部分：空课学费（2025-12-22新增） (Lines 157-186)
SELECT ... FROM v_info_tmp_lesson_after_43_month_fee_unpaid_yet
WHERE stu_id = #{stuId} ...

UNION ALL

-- 第三部分：已支付课费 (Lines 188-219)
SELECT ... FROM v_info_lesson_sum_fee_pay_over
WHERE stu_id = #{stuId} ...
```

**实际查询结果：**

| 来源 | lsn_fee_id | subject_name | lesson_type | lsn_count | lsn_fee | lsn_month |
|------|-----------|--------------|-------------|-----------|---------|-----------|
| 第一部分-未支付 | kn-fee-699 | Piano | 1 | **1.00** | 200 | 2025-12 |
| 第二部分-空课学费 | kn-fee-699 | Piano | 1 | **0.00** | 200 | 2025-12 |

**同一个课费记录(kn-fee-699)在两个UNION部分都出现了！**

### 3. 为什么会重复？

**临时课程记录：**
- `t_info_lesson_tmp` 表: kn-lsn-tmp-6 (临时课程ID)
- `t_info_lesson_fee` 表: kn-fee-699 (lesson_id = 'kn-lsn-tmp-6')
- 创建时间：执行了"生成空月课费"操作后

**第一部分查询逻辑问题：**

`v_info_lesson_sum_fee_unpaid_yet` 视图内部使用了 `v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect` 作为数据源。

查看 [v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect.sql:69-95](02DBTableGenerateTool/MySQL_KNStudent/Views/v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect.sql#L69-L95)：

```sql
-- 第一部分：正式课程（lines 12-67）
SELECT ... FROM v_info_lesson_fee_and_extraToScheDataCorrect fee ...

UNION ALL

-- 第二部分：临时课程（空月课费）(lines 71-95)
SELECT
    fee.lsn_fee_id,
    fee.lesson_id,
    1 AS lesson_type,        -- 临时课=月计划
    1 AS lsn_count,          -- 固定值1  ← 这里！
    ...
    fee.lsn_fee * 4 AS lsn_fee,
    ...
FROM t_info_lesson_fee fee
INNER JOIN v_info_lesson_tmp tmp ON fee.lesson_id = tmp.lsn_tmp_id
WHERE fee.del_flg = 0
```

**关键发现：**
- 在 `v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect` 的第二部分(临时课程)，`lsn_count` 被硬编码为 **1** (line 76)
- 这个视图被 `v_info_lesson_sum_fee_unpaid_yet` 使用
- 所以临时课费 kn-fee-699 在第一个UNION中显示为 **1.0节**

**第二部分查询逻辑：**

`v_info_tmp_lesson_after_43_month_fee_unpaid_yet` 视图专门处理空课学费，[源文件:33](02DBTableGenerateTool/MySQL_KNStudent/Views/v_info_tmp_lesson_after_43_month_fee_unpaid_yet.sql#L33)：

```sql
SELECT
    ...
    0 AS lsn_count,          -- ← 永远是0
    fee.lsn_fee * 4 as lsn_fee,
    ...
FROM v_info_lesson_tmp tmp
INNER JOIN t_info_lesson_fee fee ON tmp.lsn_tmp_id = fee.lesson_id
```

所以同一个临时课费 kn-fee-699 在第二个UNION中显示为 **0.0节**

## 重复逻辑流程图

```
sp_insert_tmp_lesson_info 存储过程
    │
    ├─→ INSERT INTO t_info_lesson_tmp (kn-lsn-tmp-6)
    │
    └─→ INSERT INTO t_info_lesson_fee (kn-fee-699, lesson_id='kn-lsn-tmp-6', own_flg=0)
            │
            ├─────────────────────────────────────────┬────────────────────────────────────────┐
            │                                         │                                        │
            ↓                                         ↓                                        ↓
    v_info_lesson_fee_connect_lsn_...(UNION ALL 第2部分)  v_info_tmp_lesson_after_43_...  (其他视图)
    包含临时课程，lsn_count=1                               专门处理空课费，lsn_count=0
            │                                         │
            ↓                                         │
    v_info_lesson_sum_fee_unpaid_yet                  │
    (第一UNION源)                                      │
            │                                         │
            │                                         │
            └──────────→ Kn02F002FeeMapper.xml ←──────┘
                        getStuFeeListByYearmonth
                        UNION ALL 合并查询
                              │
                              ↓
                        前端显示2条重复记录！
                        - Piano 月计划: 1.0节/$200 (来自第一UNION)
                        - Piano 月计划: 0.0节/$200 (来自第二UNION)
```

## 结论

### 根本原因

**同一个临时课费记录(kn-fee-699)被MyBatis查询的两个UNION部分同时选中：**

1. **第一个UNION** (`v_info_lesson_sum_fee_unpaid_yet`):
   - 通过 `v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect` 包含了临时课程
   - 临时课程的 `lsn_count` 在该视图中被设为 **1**
   - 结果：显示为 **1.0节/$200**

2. **第二个UNION** (`v_info_tmp_lesson_after_43_month_fee_unpaid_yet`):
   - 专门查询临时课程表的课费
   - 临时课程的 `lsn_count` 在该视图中被设为 **0**
   - 结果：显示为 **0.0节/$200**

### 修复建议（仅供参考，不执行修改）

**方案1：在第一个UNION中排除临时课程**

修改 [Kn02F002FeeMapper.xml:146](01FlutterApps/middle_layer_springboot/knpiano_java/src/main/resources/mybatis/mapper/Kn02F002FeeMapper.xml#L146) 附近：

```xml
<!-- 当前代码 -->
from v_info_lesson_sum_fee_unpaid_yet
<where>
    stu_id = #{stuId}
    ...
</where>

<!-- 建议修改为 -->
from v_info_lesson_sum_fee_unpaid_yet
<where>
    stu_id = #{stuId}
    AND lsn_fee_id NOT IN (
        SELECT lsn_fee_id
        FROM t_info_lesson_fee
        WHERE lesson_id LIKE 'kn-lsn-tmp-%'
    )
    ...
</where>
```

**方案2：修改视图定义**

在 `v_info_lesson_sum_fee_unpaid_yet` 视图定义中排除临时课程记录，但这可能影响其他调用该视图的地方。

## 影响范围

- **受影响功能**: 手机前端 → 学费管理 → 课费支付管理 → 学生课程费用详细页面
- **受影响学生**: 所有执行了"生成空月课费"操作的学生
- **数据正确性**: 数据库中的数据是正确的，仅是查询逻辑导致前端显示重复

## 附录：相关文件路径

### 前端
- [kn02F002LsnFeeDetail.dart](01FlutterApps/front_dart_flutter/lib/02LsnFeeMngmnt/kn02F002LsnFeeDetail.dart)
- [Kn02F002FeeBean.dart](01FlutterApps/front_dart_flutter/lib/02LsnFeeMngmnt/Kn02F002FeeBean.dart)
- [Constants.dart:88](01FlutterApps/front_dart_flutter/lib/Constants.dart#L88)

### 后端
- [Kn02F002FeeController4Mobile.java](01FlutterApps/middle_layer_springboot/knpiano_java/src/main/java/com/liu/springboot04web/controller_mobile/Kn02F002FeeController4Mobile.java)
- [Kn02F002FeeMapper.xml](01FlutterApps/middle_layer_springboot/knpiano_java/src/main/resources/mybatis/mapper/Kn02F002FeeMapper.xml)

### 数据库视图
- [v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect.sql](02DBTableGenerateTool/MySQL_KNStudent/Views/v_info_lesson_fee_connect_lsn_and_extraToScheDataCorrect.sql)
- [v_info_lesson_sum_fee_unpaid_yet.sql](02DBTableGenerateTool/MySQL_KNStudent/Views/v_info_lesson_sum_fee_unpaid_yet.sql)
- [v_info_tmp_lesson_after_43_month_fee_unpaid_yet.sql](02DBTableGenerateTool/MySQL_KNStudent/Views/v_info_tmp_lesson_after_43_month_fee_unpaid_yet.sql)

---
**调查日期**: 2025-12-27
**调查对象**: Bug4 - 语铭12月月计划课费重复显示
**数据库**: 192.168.50.101:49168/KNStudent
**学生ID**: kn-stu-62 (Lin Yuming 林语铭)
**课费ID**: kn-fee-699
**临时课程ID**: kn-lsn-tmp-6
