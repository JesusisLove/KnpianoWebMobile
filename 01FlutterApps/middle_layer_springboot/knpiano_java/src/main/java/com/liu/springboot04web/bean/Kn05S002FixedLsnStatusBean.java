package com.liu.springboot04web.bean;

import java.sql.Date;

public class Kn05S002FixedLsnStatusBean {
    private Integer     weekNumber;
    private Date        startWeekDate;
    private Date        endWeekDate;
    private Integer     fixedStatus;

    public Integer getWeekNumber() {
        return weekNumber;
    }
    public void setWeekNumber(Integer weekNumber) {
        this.weekNumber = weekNumber;
    }
    public Integer getFixedStatus() {
        return fixedStatus;
    }
    public void setFixedStatus(Integer fixedStatus) {
        this.fixedStatus = fixedStatus;
    }
    public Date getStartWeekDate() {
        return startWeekDate;
    }
    public void setStartWeekDate(Date startWeekDate) {
        this.startWeekDate = startWeekDate;
    }
    public Date getEndWeekDate() {
        return endWeekDate;
    }
    public void setEndWeekDate(Date endWeekDate) {
        this.endWeekDate = endWeekDate;
    }
}