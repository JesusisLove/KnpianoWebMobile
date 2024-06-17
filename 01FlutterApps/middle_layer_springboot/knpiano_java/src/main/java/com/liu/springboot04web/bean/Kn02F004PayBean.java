package com.liu.springboot04web.bean;

import java.util.Date;

public class Kn02F004PayBean implements KnPianoBean {

    protected String lsnPayId;
    protected String lsnFeeId;
    protected float lsnPay;
    protected String payMonth;
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
    protected String    bankName;
    protected String    lsnMonth;
    protected Integer   payStyle;
    protected float     lsnCount;
    protected float     lsnFee;

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
    public float getLsnCount() {
        return lsnCount;
    }
    public void setLsnCount(float lsnCount) {
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
    public String getBankName() {
        return bankName;
    }
    public void setBankName(String bankName) {
        this.bankName = bankName;
    }
    
}