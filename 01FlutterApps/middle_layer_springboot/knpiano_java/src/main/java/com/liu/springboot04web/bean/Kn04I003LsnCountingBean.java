package com.liu.springboot04web.bean;

public class Kn04I003LsnCountingBean implements KnPianoBean {
    private String stuId;          // 学生ID
    private String subjectId;      // 科目ID
    private int    payStyle;
    private Float totalLsnCnt0;    // 按课时收费统计的上课总数
    private Float totalLsnCnt1;    // 按计划课统计的上课总数
    private Float totalLsnCnt2;    // 按加课时统计的上课总数
    private String stuName;        // 学生姓名
    private String subjectName;    // 科目名称
    private Float yearLsnCnt;      // 年度计划总课时

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

    public int getPayStyle() {
        return payStyle;
    }

    public void setPayStyle(int payStyle) {
        this.payStyle = payStyle;
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
        public Float getTotalLsnCnt0() {
        return totalLsnCnt0;
    }

    public void setTotalLsnCnt0(Float totalLsnCnt0) {
        this.totalLsnCnt0 = totalLsnCnt0;
    }

        public Float getTotalLsnCnt1() {
        return totalLsnCnt1;
    }

    public void setTotalLsnCnt1(Float totalLsnCnt1) {
        this.totalLsnCnt1 = totalLsnCnt1;
    }

    public Float getTotalLsnCnt2() {
        return totalLsnCnt2;
    }

    public void setTotalLsnCnt2(Float totalLsnCnt2) {
        this.totalLsnCnt2 = totalLsnCnt2;
    }

        public Float getYearLsnCnt() {
        return yearLsnCnt;
    }

    public void setYearLsnCnt(Float yearLsnCnt) {
        this.yearLsnCnt = yearLsnCnt;
    }
}
