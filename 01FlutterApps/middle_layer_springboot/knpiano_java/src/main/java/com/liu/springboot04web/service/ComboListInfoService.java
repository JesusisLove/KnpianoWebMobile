package com.liu.springboot04web.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.util.List;

@Component
public class ComboListInfoService {

    @Value("${lesson_durations}")// 给学生排课时上课的时长
    private List<String> durations;
    public List<String> getDurations() {
        return durations;
    }

    @Value("${set_durations}")// 不同阶段的上课时长
    private List<String> minutesPerLsn;
    public List<String> getMinutesPerLsn() {
            return minutesPerLsn;
        }

    @Value("${regular_week}")// 星期一到星期日
    private List<String> regularWeek;
    public List<String> getRegularWeek() {
        return regularWeek;
    }

    @Value("${regular_hour}")// 固定上课在几点
    private List<String> regularHour;
    public List<String> getRegularHour() {
        return regularHour;
    }

    @Value("${regular_minute}")// 固定上课在几点
    private List<String> regularMinute;
    public List<String> getRegularMinute() {
        return regularMinute;
    }   
}
