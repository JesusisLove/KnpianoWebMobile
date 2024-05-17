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
}