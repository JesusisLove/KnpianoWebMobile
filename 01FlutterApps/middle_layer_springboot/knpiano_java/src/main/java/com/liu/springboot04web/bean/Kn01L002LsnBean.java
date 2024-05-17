package com.liu.springboot04web.bean;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

public class Kn01L002LsnBean implements KnPianoBean {

    protected String lessonId;
    protected String subjectId;
    protected String subjectName;
    protected String stuId;
    protected String stuName;
    protected Integer classDuration;
    protected Integer lessonType;
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm")
    protected Date schedualDate;
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm")
    protected Date scanQRDate;
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm")
    protected Date lsnAdjustedDate;
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm")
    protected Date extraToDurDate;
    protected Integer delFlg;
    protected Date createDate;
    protected Date updateDate;
    public String getLessonId() {
        return lessonId;
    }
    public void setLessonId(String lessonId) {
        this.lessonId = lessonId;
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
    public Integer getClassDuration() {
        return classDuration;
    }
    public void setClassDuration(Integer classDuration) {
        this.classDuration = classDuration;
    }
    public Integer getLessonType() {
        return lessonType;
    }
    public void setLessonType(Integer lessonType) {
        this.lessonType = lessonType;
    }
    public Date getSchedualDate() {
        return schedualDate;
    }
    public void setSchedualDate(Date schedualDate) {
        this.schedualDate = schedualDate;
    }
    public Date getScanQRDate() {
        return scanQRDate;
    }
    public void setScanQRDate(Date scanQRDate) {
        this.scanQRDate = scanQRDate;
    }
    public Date getLsnAdjustedDate() {
        return lsnAdjustedDate;
    }
    public void setLsnAdjustedDate(Date lsnAdjustedDate) {
        this.lsnAdjustedDate = lsnAdjustedDate;
    }
    public Date getExtraToDurDate() {
        return extraToDurDate;
    }
    public void setExtraToDurDate(Date extraToDurDate) {
        this.extraToDurDate = extraToDurDate;
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

}
