package com.liu.springboot04web.bean;

import org.springframework.format.annotation.DateTimeFormat;
import java.util.Date;

/**
 * 固定授業計画管理（Fixed Lesson Plan Management）的数据模型，实现 BzlFudousanBean 接口。
 */
public class KnFixfLsn001Bean implements BzlFudousanBean {
    private String stuId;          // 学生ID
    private String subjectId;      // 科目ID
    private String fixedWeek;      // 固定的星期
    private Integer fixedHour;     // 固定的小时
    private Integer fixedMinute;   // 固定的分钟

    // 创建日期和更新日期字段，假设这些信息是需要的
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date createDate;       // 创建日期
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private Date updateDate;       // 更新日期

    // Getter 和 Setter 方法
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

    public String getFixedWeek() {
        return fixedWeek;
    }

    public void setFixedWeek(String fixedWeek) {
        this.fixedWeek = fixedWeek;
    }

    public Integer getFixedHour() {
        return fixedHour;
    }

    public void setFixedHour(Integer fixedHour) {
        this.fixedHour = fixedHour;
    }

    public Integer getFixedMinute() {
        return fixedMinute;
    }

    public void setFixedMinute(Integer fixedMinute) {
        this.fixedMinute = fixedMinute;
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
