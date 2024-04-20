package com.liu.springboot04web.bean;
import org.springframework.format.annotation.DateTimeFormat;

import java.text.SimpleDateFormat;
import java.util.Date;

public class KnStudoc001Bean implements KnPianoBean {

    protected String stuId;
    protected String subjectId;
    protected String stuName;
    protected String subjectName;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    protected Date adjustedDate;
    protected Integer payStyle;
    protected Integer minutesPerLsn;
    protected float lessonFee;
    protected float lessonFeeAdjusted;
    protected Integer delFlg;
    protected Date createDate;
    protected Date updateDate;

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
    public Date getAdjustedDate() {
        return adjustedDate;
    }
    public void setAdjustedDate(Date adjustedDate) {
        this.adjustedDate = adjustedDate;
    }
    public Integer getPayStyle() {
        return payStyle;
    }
    public void setPayStyle(Integer payStyle) {
        this.payStyle = payStyle;
    }
    public Integer getMinutesPerLsn() {
        return minutesPerLsn;
    }
    public void setMinutesPerLsn(Integer minutesPerLsn) {
        this.minutesPerLsn = minutesPerLsn;
    }
    public float getLessonFee() {
        return lessonFee;
    }
    public void setLessonFee(float lessonFee) {
        this.lessonFee = lessonFee;
    }
    public float getLessonFeeAdjusted() {
        return lessonFeeAdjusted;
    }
    public void setLessonFeeAdjusted(float lessonFeeAdjusted) {
        this.lessonFeeAdjusted = lessonFeeAdjusted;
    }
    public Integer getDelFlg() {
        return delFlg;
    }
    public void setDelFlg(Integer delFlg) {
        this.delFlg = delFlg;
    }
    public Date getCreateDate() {
        return createDate;
    }
    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }
    public Date getUpdateDate() {
        return updateDate;
    }
    public void setUpdateDate(Date updateDate) {
        this.updateDate = updateDate;
    }
    
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    public String toString() {
        return "KnStudoc001Bean{" +
                "stuId='" + stuId + '\'' +
                ", subjectId='" + subjectId + '\'' +
                ", stuName='" + stuName + '\'' +
                ", subjectName='" + subjectName + '\'' +
                ", adjustedDate=" + (adjustedDate != null ? dateFormat.format(adjustedDate) : "null") +
                ", payStyle=" + payStyle +
                ", lessonFee=" + lessonFee +
                ", lessonFeeAdjusted=" + lessonFeeAdjusted +
                ", delFlg=" + delFlg +
                ", createDate=" + (createDate != null ? dateFormat.format(createDate) : "null") +
                ", updateDate=" + (updateDate != null ? dateFormat.format(updateDate) : "null") +
                '}';
    }
}
