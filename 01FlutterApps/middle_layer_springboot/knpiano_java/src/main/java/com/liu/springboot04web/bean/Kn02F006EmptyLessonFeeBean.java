package com.liu.springboot04web.bean;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;

/**
 * 空课学费按月支付Bean
 * 用于显示达到43节课的学生列表
 */
public class Kn02F006EmptyLessonFeeBean {
    protected String stuId;
    protected String stuName;
    protected String subjectId;
    protected String subjectName;
    protected Double cumulativeCount;    // 累计课程数
    protected Integer monthsCompleted;    // 完成月份数
    protected String year;                // 年度（用于生成临时课程）
    protected Integer hasGenerated;       // 是否已生成临时课程（1=已生成，0=未生成）

    // 月度明细相关字段
    protected String lsnTmpId;            // 临时课程ID
    protected String lsnFeeId;            // 课费ID
    @JsonFormat(pattern = "yyyy/MM/dd HH:mm:ss", timezone = "GMT+8")
    protected Date schedualDate;          // 排课日期
    protected Double lsnFee;              // 课费金额
    protected String ownFlg;              // 结算标志（1=已结算，0=未结算）

    public String getStuId() {
        return stuId;
    }

    public void setStuId(String stuId) {
        this.stuId = stuId;
    }

    public String getStuName() {
        return stuName;
    }

    public void setStuName(String stuName) {
        this.stuName = stuName;
    }

    public String getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(String subjectId) {
        this.subjectId = subjectId;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public Double getCumulativeCount() {
        return cumulativeCount;
    }

    public void setCumulativeCount(Double cumulativeCount) {
        this.cumulativeCount = cumulativeCount;
    }

    public Integer getMonthsCompleted() {
        return monthsCompleted;
    }

    public void setMonthsCompleted(Integer monthsCompleted) {
        this.monthsCompleted = monthsCompleted;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }

    public Integer getHasGenerated() {
        return hasGenerated;
    }

    public void setHasGenerated(Integer hasGenerated) {
        this.hasGenerated = hasGenerated;
    }

    public String getLsnTmpId() {
        return lsnTmpId;
    }

    public void setLsnTmpId(String lsnTmpId) {
        this.lsnTmpId = lsnTmpId;
    }

    public String getLsnFeeId() {
        return lsnFeeId;
    }

    public void setLsnFeeId(String lsnFeeId) {
        this.lsnFeeId = lsnFeeId;
    }

    public Date getSchedualDate() {
        return schedualDate;
    }

    public void setSchedualDate(Date schedualDate) {
        this.schedualDate = schedualDate;
    }

    public Double getLsnFee() {
        return lsnFee;
    }

    public void setLsnFee(Double lsnFee) {
        this.lsnFee = lsnFee;
    }

    public String getOwnFlg() {
        return ownFlg;
    }

    public void setOwnFlg(String ownFlg) {
        this.ownFlg = ownFlg;
    }
}
