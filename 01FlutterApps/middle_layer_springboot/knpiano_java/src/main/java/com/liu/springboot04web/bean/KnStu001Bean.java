package com.liu.springboot04web.bean;

import java.util.Date;

public class KnStu001Bean implements KnPianoBean {
    protected String stuId;
    protected String stuName;
    protected Integer gender;
    protected String birthday;
    protected String tel1;
    protected String tel2;
    protected String tel3;
    protected String tel4;
    protected String address;
    protected String postCode;
    protected String introducer;
    protected Integer delFlg;

    private Date createDate;

    private Date updateDate;

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
    public Integer getGender() {
        return gender;
    }
    public void setGender(Integer gender) {
        this.gender = gender;
    }
    public String getBirthday() {
        return birthday;
    }
    public void setBirthday(String birthday) {
        this.birthday = birthday;
    }
    public String getTel1() {
        return tel1;
    }
    public void setTel1(String tel1) {
        this.tel1 = tel1;
    }
    public String getTel2() {
        return tel2;
    }
    public void setTel2(String tel2) {
        this.tel2 = tel2;
    }
    public String getTel3() {
        return tel3;
    }
    public void setTel3(String tel3) {
        this.tel3 = tel3;
    }
    public String getTel4() {
        return tel4;
    }
    public void setTel4(String tel4) {
        this.tel4 = tel4;
    }
    public String getAddress() {
        return address;
    }
    public void setAddress(String address) {
        this.address = address;
    }
    public String getPostCode() {
        return postCode;
    }
    public void setPostCode(String postCode) {
        this.postCode = postCode;
    }
    public Integer getDelFlg() {
        return delFlg;
    }
    public void setDelFlg(Integer delFlg) {
        this.delFlg = delFlg;
    }
    public String getIntroducer() {
        return introducer;
    }
    public void setIntroducer(String introducer) {
        this.introducer = introducer;
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
