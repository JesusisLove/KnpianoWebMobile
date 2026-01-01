package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F006EmptyLessonFeeBean;

import java.util.List;

@Mapper
public interface Kn02F006EmptyLessonFeeMapper {

    /**
     * 查询在指定年度达到43节课的学生列表
     * 排除已在临时课程表中存在相同年度记录的学生
     *
     * @param year 年度 (例如: "2025")
     * @return 达到43节课的学生列表
     */
    List<Kn02F006EmptyLessonFeeBean> getStudentsReached43Lessons(@Param("year") String year);

    /**
     * 调用存储过程生成临时课程和课费
     *
     * @param stuId       学生ID
     * @param subjectId   科目ID
     * @param targetDate  目标日期 (格式: YYYY-MM-DD)
     */
    void callInsertTmpLessonInfo(
        @Param("stuId") String stuId,
        @Param("subjectId") String subjectId,
        @Param("targetDate") String targetDate
    );

    /**
     * 查询某个学生某个科目在指定年度的空月课费月度明细
     *
     * @param stuId     学生ID
     * @param subjectId 科目ID
     * @param year      年度 (例如: "2025")
     * @return 月度明细列表
     */
    List<Kn02F006EmptyLessonFeeBean> getMonthlyDetailsForCancel(
        @Param("stuId") String stuId,
        @Param("subjectId") String subjectId,
        @Param("year") String year
    );

    /**
     * 调用存储过程撤销空月课费
     *
     * @param lsnTmpId 临时课程ID
     * @param lsnFeeId 课费ID
     */
    void callCancelTmpLessonInfo(
        @Param("lsnTmpId") String lsnTmpId,
        @Param("lsnFeeId") String lsnFeeId
    );
}
