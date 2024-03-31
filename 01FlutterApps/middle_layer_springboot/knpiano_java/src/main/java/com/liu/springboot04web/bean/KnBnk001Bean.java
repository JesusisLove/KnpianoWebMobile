package com.liu.springboot04web.bean;

import org.springframework.format.annotation.DateTimeFormat;
import java.util.Date;

public class KnBnk001Bean implements BzlFudousanBean {
    private String bankId;
    private String bankName;
    private Integer delFlg;

    @DateTimeFormat(pattern = "yyyy/MM/dd")
    private Date createDate;

    @DateTimeFormat(pattern = "yyyy/MM/dd")
    private Date updateDate;

    public String getBankId() {
        return bankId;
    }

    public void setBankId(String bankId) {
        this.bankId = bankId;
    }

    public String getBankName() {
        return bankName;
    }

    public void setBankName(String bankName) {
        this.bankName = bankName;
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
