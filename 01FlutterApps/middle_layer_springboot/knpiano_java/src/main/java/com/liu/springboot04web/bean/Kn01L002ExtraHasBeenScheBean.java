package com.liu.springboot04web.bean;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import com.fasterxml.jackson.annotation.JsonFormat;

public class Kn01L002ExtraHasBeenScheBean {
    protected String stuId;
    protected String stuName;
    protected String lessonId;
    protected String subjectId;
    protected String subjectName;
    protected String oldSubjectSubId;
    protected String oldSubjectSubName;
    protected float oldLsnFee;
    protected String newSubjectSubId;
    protected String newSubjectSubName;
    protected float newLsnFee;
    protected Integer isGoodChange;
    protected String memoReason;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm") // timezone = "GMT+8" 的设置被统一到了application.properties里
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    protected Date fromExtraScanDate;

    protected Date toScheScanDate;

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
    public String getOldSubjectSubId() {
        return oldSubjectSubId;
    }
    public void setOldSubjectSubId(String oldSubjectSubId) {
        this.oldSubjectSubId = oldSubjectSubId;
    }
    public String getOldSubjectSubName() {
        return oldSubjectSubName;
    }
    public void setOldSubjectSubName(String oldSubjectSubName) {
        this.oldSubjectSubName = oldSubjectSubName;
    }
    public float getOldLsnFee() {
        return oldLsnFee;
    }
    public void setOldLsnFee(float oldLsnFee) {
        this.oldLsnFee = oldLsnFee;
    }
    public String getNewSubjectSubId() {
        return newSubjectSubId;
    }
    public void setNewSubjectSubId(String newSubjectSubId) {
        this.newSubjectSubId = newSubjectSubId;
    }
    public String getNewSubjectSubName() {
        return newSubjectSubName;
    }
    public void setNewSubjectSubName(String newSubjectSubName) {
        this.newSubjectSubName = newSubjectSubName;
    }
    public float getNewLsnFee() {
        return newLsnFee;
    }
    public void setNewLsnFee(float newLsnFee) {
        this.newLsnFee = newLsnFee;
    }
    public Date getFromExtraScanDate() {
        return fromExtraScanDate;
    }
    public void setFromExtraScanDate(Date fromExtraScanDate) {
        this.fromExtraScanDate = fromExtraScanDate;
    }
    public Date getToScheScanDate() {
        return toScheScanDate;
    }
    public void setToScheScanDate(Date toScheScanDate) {
        this.toScheScanDate = toScheScanDate;
    }
    public Integer getIsGoodChange() {
        return isGoodChange;
    }
    public void setIsGoodChange(Integer isGoodChange) {
        this.isGoodChange = isGoodChange;
    }
    public String getMemoReason() {
        return memoReason;
    }
    public void setMemoReason(String memoReason) {
        this.memoReason = memoReason;
    }


}
