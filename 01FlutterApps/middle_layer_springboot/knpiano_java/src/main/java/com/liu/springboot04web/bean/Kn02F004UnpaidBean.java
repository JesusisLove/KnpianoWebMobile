package com.liu.springboot04web.bean;

import java.util.Date;

import org.springframework.format.annotation.DateTimeFormat;

import com.fasterxml.jackson.annotation.JsonFormat;

public class Kn02F004UnpaidBean implements KnPianoBean {

    protected String lsnPayId;
    protected String lsnFeeId;
    protected float lsnPay;
    protected String payMonth;
    
    // @JsonFormat(pattern = "yyyy-MM-dd HH:mm", 
    // // timezone = "GMT+9" // 采用东京标准时区，接受手机前端的请求时接纳前端String类型的日期值
    // timezone = "GMT+8" // 采用新加坡标准时区，接受手机前端的请求时接纳前端String类型的日期值
    // )
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm") // timezone = "GMT+8" 的设置被统一到了application.properties里
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm")// 后台维护页面的请求响应处理
    protected Date payDate;

    protected String bankId;
    protected Integer delFlg;
    protected Date createDate;
    protected Date updateDate;

    // 表关联项目
    protected Integer   lessonType;
    protected String    stuId;
    protected String    subjectId;
    protected String    subjectSubId;
    protected String    stuName;
    protected String    subjectName;
    protected String    subjectSubName;
    protected String    lsnMonth;
    protected Integer   payStyle;
    protected Integer   lsnCount;
    protected float     lsnFee;
    protected Integer   ownFlg;
    // 为了按月交费的计划课的精算业务，需要《学生档案》表里对象科目的最新价格
    protected float     subjectPrice;

    public String getLsnPayId() {
        return lsnPayId;
    }
    public void setLsnPayId(String lsnPayId) {
        this.lsnPayId = lsnPayId;
    }
    public String getLsnFeeId() {
        return lsnFeeId;
    }
    public void setLsnFeeId(String lsnFeeId) {
        this.lsnFeeId = lsnFeeId;
    }
    public float getLsnPay() {
        return lsnPay;
    }
    public void setLsnPay(float lsnPay) {
        this.lsnPay = lsnPay;
    }
    public String getPayMonth() {
        return payMonth;
    }
    public void setPayMonth(String payMonth) {
        this.payMonth = payMonth;
    }
    public String getBankId() {
        return bankId;
    }
    public void setBankId(String bankId) {
        this.bankId = bankId;
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
    public Integer getLessonType() {
        return lessonType;
    }
    public void setLessonType(Integer lessonType) {
        this.lessonType = lessonType;
    }
    public String getStuId() {
        return stuId;
    }
    public void setStuId(String stuId) {
        this.stuId = stuId;
    }
    public String getSubjectId() {
        return subjectId;
    }
    public void setSubjectId(String subjectId) {
        this.subjectId = subjectId;
    }
    public String getStuName() {
        return stuName;
    }
    public void setStuName(String stuName) {
        this.stuName = stuName;
    }
    public String getSubjectName() {
        return subjectName;
    }
    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }
    public Integer getPayStyle() {
        return payStyle;
    }
    public void setPayStyle(Integer payStyle) {
        this.payStyle = payStyle;
    }
    public Integer getLsnCount() {
        return lsnCount;
    }
    public void setLsnCount(Integer lsnCount) {
        this.lsnCount = lsnCount;
    }
    public String getLsnMonth() {
        return lsnMonth;
    }
    public void setLsnMonth(String lsnMonth) {
        this.lsnMonth = lsnMonth;
    }
    public float getLsnFee() {
        return lsnFee;
    }
    public void setLsnFee(float lsnFee) {
        this.lsnFee = lsnFee;
    }
    public String getSubjectSubId() {
        return subjectSubId;
    }
    public void setSubjectSubId(String subjectSubId) {
        this.subjectSubId = subjectSubId;
    }
    public String getSubjectSubName() {
        return subjectSubName;
    }
    public void setSubjectSubName(String subjectSubName) {
        this.subjectSubName = subjectSubName;
    }
    public Integer getOwnFlg() {
        return ownFlg;
    }
    public void setOwnFlg(Integer ownFlg) {
        this.ownFlg = ownFlg;
    }
    public float getSubjectPrice() {
        return subjectPrice;
    }
    public void setSubjectPrice(float subjectPrice) {
        this.subjectPrice = subjectPrice;
    }
    public Date getPayDate() {
        return payDate;
    }
    public void setPayDate(Date payDate) {
        this.payDate = payDate;
    }

}