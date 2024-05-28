package com.liu.springboot04web.constant;

public final class KNConstant {

    /* 学生番号自動採番 */
    public static final String CONSTANT_KN_STU_SEQ = "kn-stu-";
    /* 科目番号自動採番 */
    public static final String CONSTANT_KN_SUB_SEQ = "kn-sub-";
    /* 銀行番号自動採番 */
    public static final String CONSTANT_KN_BNK_SEQ = "kn-bnk-";
    /* 授業番号自動採番 */
    public static final String CONSTANT_KN_LSN_SEQ = "kn-lsn-";
    /* 授業課費番号自動採番 */
    public static final String CONSTANT_KN_LSN_FEE_SEQ = "kn-lsn-fee-";
    /* 授業支払番号自動採番 */
    public static final String CONSTANT_KN_LSN_PAY_SEQ = "kn-lsn-pay-";

    // 0：按课时计算
    public static final Integer CONSTANT_LESSON_TYPE_TIAMLY = 0; 
    // 1：按月计划课
    public static final Integer CONSTANT_LESSON_TYPE_MONTHLY_SCHEDUAL = 1; 
    // 2：按月加时课
    public static final Integer CONSTANT_LESSON_TYPE_MONTHLY_ADDITIONAL = 2; 
    

}