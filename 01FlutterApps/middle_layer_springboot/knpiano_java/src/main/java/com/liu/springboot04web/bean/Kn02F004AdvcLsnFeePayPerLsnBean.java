package com.liu.springboot04web.bean;

public class Kn02F004AdvcLsnFeePayPerLsnBean extends Kn02F003AdvcLsnFeePayBean {
    // 按课时预支付时，用户指定的课时数（一次性预支付多少节课）
    private Integer lessonCount;

    public Integer getLessonCount() {
        return lessonCount;
    }
    public void setLessonCount(Integer lessonCount) {
        this.lessonCount = lessonCount;
    }
}
