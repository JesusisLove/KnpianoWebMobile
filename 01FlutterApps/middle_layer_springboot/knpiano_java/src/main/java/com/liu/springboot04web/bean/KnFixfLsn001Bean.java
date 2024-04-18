package com.liu.springboot04web.bean;

/**
 * 固定授業計画管理（Fixed Lesson Plan Management）的数据模型，实现 BzlFudousanBean 接口。
 */
public class KnFixfLsn001Bean implements KnPianoBean {
    private String stuId;          // 学生ID
    private String subjectId;      // 科目ID
    private String fixedWeek;      // 固定的星期
    private Integer fixedHour;     // 固定的小时
    private Integer fixedMinute;   // 固定的分钟

    private String stuName;
    private String subjectName;

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
}
