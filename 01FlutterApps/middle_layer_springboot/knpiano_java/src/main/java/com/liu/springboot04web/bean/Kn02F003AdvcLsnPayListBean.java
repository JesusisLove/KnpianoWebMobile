package com.liu.springboot04web.bean;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import com.fasterxml.jackson.annotation.JsonFormat;

public class Kn02F003AdvcLsnPayListBean {
protected String    lessonId;
    protected String    lsnFeeId;
    protected String    lsnPayId;
    protected String    subjectId;
    protected String    subjectSubId;
    protected String    subjectName;
    protected String    subjectSubName;
    protected String    stuId;
    protected String    stuName;
    protected String    nikName;
    protected Integer   classDuration;
    protected Integer   lessonType;
    protected Integer   schedualType;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm") // timezone = "GMT+8" 的设置被统一到了application.properties里
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm")// 后台维护页面的请求响应处理
    protected Date      schedualDate;
    protected Integer   payStyle;

    // 为了按月交费的计划课的精算业务，需要《学生档案》表里对象科目的最新价格
    protected float     subjectPrice;
    protected Integer   minutesPerLsn;
    protected float     lsnPay;
    protected String    bankId;
    protected String    bankName;
    protected Integer   advcFlg;

    public String getSubjectId() {
        return subjectId;
    }
    public void setSubjectId(String subjectId) {
        this.subjectId = subjectId;
    }
    public String getSubjectSubId() {
        return subjectSubId;
    }
    public void setSubjectSubId(String subjectSubId) {
        this.subjectSubId = subjectSubId;
    }
    public String getSubjectName() {
        return subjectName;
    }
    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }
    public String getSubjectSubName() {
        return subjectSubName;
    }
    public void setSubjectSubName(String subjectSubName) {
        this.subjectSubName = subjectSubName;
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
    public String getNikName() {
        return nikName;
    }
    public void setNikName(String nikName) {
        this.nikName = nikName;
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
    public Integer getSchedualType() {
        return schedualType;
    }
    public void setSchedualType(Integer schedualType) {
        this.schedualType = schedualType;
    }
    public Date getSchedualDate() {
        return schedualDate;
    }
    public void setSchedualDate(Date schedualDate) {
        this.schedualDate = schedualDate;
    }

    public Integer getPayStyle() {
        return payStyle;
    }
    public void setPayStyle(Integer payStyle) {
        this.payStyle = payStyle;
    }
    public float getSubjectPrice() {
        return subjectPrice;
    }
    public void setSubjectPrice(float subjectPrice) {
        this.subjectPrice = subjectPrice;
    }
    public Integer getMinutesPerLsn() {
        return minutesPerLsn;
    }
    public void setMinutesPerLsn(Integer minutesPerLsn) {
        this.minutesPerLsn = minutesPerLsn;
    }
    public String getBankId() {
        return bankId;
    }
    public void setBankId(String bankId) {
        this.bankId = bankId;
    }
    public String getLessonId() {
        return lessonId;
    }
    public void setLessonId(String lessonId) {
        this.lessonId = lessonId;
    }
    public String getLsnFeeId() {
        return lsnFeeId;
    }
    public void setLsnFeeId(String lsnFeeId) {
        this.lsnFeeId = lsnFeeId;
    }
    public String getLsnPayId() {
        return lsnPayId;
    }
    public void setLsnPayId(String lsnPayId) {
        this.lsnPayId = lsnPayId;
    }
    public String getBankName() {
        return bankName;
    }
    public void setBankName(String bankName) {
        this.bankName = bankName;
    }
    public float getLsnPay() {
        return lsnPay;
    }
    public void setLsnPay(float lsnPay) {
        this.lsnPay = lsnPay;
    }
    public Integer getAdvcFlg() {
        return advcFlg;
    }
    public void setAdvcFlg(Integer advcFlg) {
        this.advcFlg = advcFlg;
    }

}
