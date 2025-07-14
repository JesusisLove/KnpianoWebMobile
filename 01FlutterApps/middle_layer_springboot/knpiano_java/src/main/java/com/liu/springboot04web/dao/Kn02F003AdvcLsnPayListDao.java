package com.liu.springboot04web.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F003AdvcLsnPayListBean;

public interface Kn02F003AdvcLsnPayListDao {


    /**
     * 根据年度获取预支付学生姓名列表
     * 用于下拉列表框数据源，获取指定年度内有预支付记录的学生信息
     * 
     * @param year 年度 (格式: yyyy，如: "2024")
     * @return 预支付学生信息列表，包含学生ID、姓名等基本信息
     */
    public List<Kn02F003AdvcLsnPayListBean> getAdvcLsnPayStuName(@Param("year") String year);


    /**
     * 根据学生ID和年度获取预支付历史记录明细列表
     * 用于显示指定学生在指定年度的所有预支付记录详情
     * 
     * @param stuId 学生ID (如: "kn-stu-41")
     * @param year 年度 (格式: yyyy，如: "2024") 
     * @return 预支付历史记录明细列表，包含课程信息、费用信息、支付状态等完整数据
     */
    public List<Kn02F003AdvcLsnPayListBean> getAdvcLsnPayList(@Param("stuId") String stuId, @Param("year") String year);


    /** 预支付再调整用
     * 获取有效的预支付课程ID
     * @param stuId 学生ID
     * @param subjectId 科目ID  
     * @param lessonId  课程ID
     * @return 课程ID，如果没有找到返回null
     */
    String getValidAdvancePaymentLessonId(@Param("stuId") String stuId, 
                                          @Param("subjectId") String subjectId,
                                          @Param("lessonId") String lessonId);

    /** 预支付再调整用
     * 更新预支付记录
     * @param newLessonId 新的课程ID（用于替换的有效课程ID）
     * @param oldLessonId 原课程ID（需要被替换的课程ID）
     * @param lsnFeeId 课费ID
     * @param lsnPayId 支付ID
     * @return 受影响的行数
     */
    int updateAdvancePayment(@Param("lessonId") String newLessonId,
                             @Param("oldLessonId") String oldLessonId,
                             @Param("lsnFeeId") String lsnFeeId,
                             @Param("lsnPayId") String lsnPayId);

    /** 预支付再调整用
     * 从《课费表》里删除无效的预支付课程ID
     * @param lessonId 课程ID
     * @return 受影响的行数
     */
    int deleteInvalidAdvancePaymentLessonId(@Param("lessonId") String lessonId);
                                          
}
