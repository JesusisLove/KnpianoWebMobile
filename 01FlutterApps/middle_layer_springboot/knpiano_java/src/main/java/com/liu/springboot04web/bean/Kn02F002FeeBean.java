package com.liu.springboot04web.bean;

import java.util.Date;

public class Kn02F002FeeBean implements KnPianoBean{
    protected String lsnFeeId;
    protected String lessonId;
    protected float lsnFee;
    protected String lsnMonth;
    protected Integer ownFlg;
    protected Integer delFlg;
    protected Date createDate;
    protected Date updateDate;
    public String getLsnFeeId() {
        return lsnFeeId;
    }
    public void setLsnFeeId(String lsnFeeId) {
        this.lsnFeeId = lsnFeeId;
    }
    public String getLessonId() {
        return lessonId;
    }
    public void setLessonId(String lessonId) {
        this.lessonId = lessonId;
    }
    public float getLsnFee() {
        return lsnFee;
    }
    public void setLsnFee(float lsnFee) {
        this.lsnFee = lsnFee;
    }
    public String getLsnMonth() {
        return lsnMonth;
    }
    public void setLsnMonth(String lsnMonth) {
        this.lsnMonth = lsnMonth;
    }
    public Integer getOwnFlg() {
        return ownFlg;
    }
    public void setOwnFlg(Integer ownFlg) {
        this.ownFlg = ownFlg;
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
