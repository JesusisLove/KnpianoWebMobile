package com.liu.springboot04web.bean;

public class Kn02f005FeeMonthlyReportBean implements KnPianoBean {

    protected float     shouldPayLsnFee;
    protected float     hasPaidLsnFee;
    protected float     unpaidLsnFee;
    protected String    lsnMonth;
    protected String    stuName;
    protected String    stuId;

    public float getShouldPayLsnFee() {
        return shouldPayLsnFee;
    }
    public void setShouldPayLsnFee(float shouldPayLsnFee) {
        this.shouldPayLsnFee = shouldPayLsnFee;
    }
    public float getHasPaidLsnFee() {
        return hasPaidLsnFee;
    }
    public void setHasPaidLsnFee(float hasPaidLsnFee) {
        this.hasPaidLsnFee = hasPaidLsnFee;
    }
    public float getUnpaidLsnFee() {
        return unpaidLsnFee;
    }
    public void setUnpaidLsnFee(float unpaidLsnFee) {
        this.unpaidLsnFee = unpaidLsnFee;
    }
    public String getLsnMonth() {
        return lsnMonth;
    }
    public void setLsnMonth(String lsnMonth) {
        this.lsnMonth = lsnMonth;
    }
    public String getStuName() {
        return stuName;
    }
    public void setStuName(String stuName) {
        this.stuName = stuName;
    }
    public String getStuId() {
        return stuId;
    }
    public void setStuId(String stuId) {
        this.stuId = stuId;
    }

}
