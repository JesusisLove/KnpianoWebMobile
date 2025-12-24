package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn02F006EmptyLessonFeeBean;
import com.liu.springboot04web.mapper.Kn02F006EmptyLessonFeeMapper;

import java.util.List;

@Repository
public class Kn02F006EmptyLessonFeeDao {

    @Autowired
    private Kn02F006EmptyLessonFeeMapper kn02F006EmptyLessonFeeMapper;

    /**
     * 查询在指定年度达到43节课的学生列表
     *
     * @param year 年度 (例如: "2025")
     * @return 达到43节课的学生列表
     */
    public List<Kn02F006EmptyLessonFeeBean> getStudentsReached43Lessons(String year) {
        return kn02F006EmptyLessonFeeMapper.getStudentsReached43Lessons(year);
    }

    /**
     * 调用存储过程生成临时课程和课费
     *
     * @param stuId       学生ID
     * @param subjectId   科目ID
     * @param targetDate  目标日期 (格式: YYYY-MM-DD)
     */
    public void callInsertTmpLessonInfo(String stuId, String subjectId, String targetDate) {
        kn02F006EmptyLessonFeeMapper.callInsertTmpLessonInfo(stuId, subjectId, targetDate);
    }

    /**
     * 查询某个学生某个科目在指定年度的空月课费月度明细
     *
     * @param stuId     学生ID
     * @param subjectId 科目ID
     * @param year      年度 (例如: "2025")
     * @return 月度明细列表
     */
    public List<Kn02F006EmptyLessonFeeBean> getMonthlyDetailsForCancel(String stuId, String subjectId, String year) {
        return kn02F006EmptyLessonFeeMapper.getMonthlyDetailsForCancel(stuId, subjectId, year);
    }

    /**
     * 调用存储过程撤销空月课费
     *
     * @param lsnTmpId 临时课程ID
     * @param lsnFeeId 课费ID
     */
    public void callCancelTmpLessonInfo(String lsnTmpId, String lsnFeeId) {
        kn02F006EmptyLessonFeeMapper.callCancelTmpLessonInfo(lsnTmpId, lsnFeeId);
    }
}
