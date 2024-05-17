package com.liu.springboot04web.bean;

import java.math.BigDecimal;
import java.util.Date;

public class Kn01L001SubBean implements KnPianoBean{
    private String subjectId;
    private String subjectName;
    private BigDecimal subjectPrice;
    private Integer delFlg;
    private Date createDate;
    private Date updateDate;

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
    public BigDecimal getSubjectPrice() {
        return subjectPrice;
    }
    public void setSubjectPrice(BigDecimal subjectPrice) {
        this.subjectPrice = subjectPrice;
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
