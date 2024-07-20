package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.WeekFields;
import java.util.List;
import java.util.Locale;

import com.liu.springboot04web.bean.Kn05S002FixedLsnStatusBean;
import com.liu.springboot04web.bean.KnPianoBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn05S002WeekCalculatorMapper;

@Repository
public class Kn05S002WeekCalculatorDao implements InterfaceKnPianoDao {

@Autowired
    private Kn05S002WeekCalculatorMapper weekCalculatorMapper;

    @Transactional
    public void insertWeeksForYear(int year) {
        LocalDate date = LocalDate.of(year, 1, 1);
        WeekFields weekFields = WeekFields.of(Locale.getDefault());

        while (date.getYear() == year) {
            int weekNumber = date.get(weekFields.weekOfWeekBasedYear());
            LocalDate weekStart = date.with(DayOfWeek.MONDAY);
            LocalDate weekEnd = date.with(DayOfWeek.SUNDAY);

            if (weekStart.getYear() < year) {
                date = date.plusWeeks(1);
                continue;
            }

            Kn05S002FixedLsnStatusBean status = new Kn05S002FixedLsnStatusBean();
            status.setWeekNumber(weekNumber);
            status.setStartWeekDate(java.sql.Date.valueOf(weekStart));
            status.setEndWeekDate(java.sql.Date.valueOf(weekEnd));

            weekCalculatorMapper.insertFixedLessonStatus(status);

            date = date.plusWeeks(1);
        }
    }

    @Override
    public List<Kn05S002FixedLsnStatusBean> getInfoList() {
        List<Kn05S002FixedLsnStatusBean> list =weekCalculatorMapper.getInfoList();
        return list;
    }

    public void deleteAll() {
        weekCalculatorMapper.deleteAll();
    }

    // 执行一周的固定排课计划
    public void excuteLsnWeeklySchedual(@RequestParam String weekStart,
                                        @RequestParam String weekEnd) {
            // 开始一周的排课
            weekCalculatorMapper.doLsnWeeklySchedual(weekStart, weekEnd, KNConstant.CONSTANT_KN_LSN_SEQ);

            // 更新年度batch周次表的排课状态（fixed_status:0表示该周的batch排课未执行，1表示该周的batch排课完了）
            weekCalculatorMapper.updateWeeklyBatchStatus(weekStart, weekEnd, 1);
    }

    // 撤销一周的固定排课计划
    public boolean cancelLsnWeeklySchedual(@PathVariable String weekStart,
                                            @PathVariable String weekEnd) {
        boolean blnstatus;                                       
        if (isCancelbale(weekStart, weekEnd)) {
            // 一旦该星期的学生有但凡有一节课已经签到，那么整个星期的排课撤销操作执行不可🙅‍♂️
            weekCalculatorMapper.updateWeeklyBatchStatus(weekStart,weekEnd, 0);

            // 删除课程表里该当日期范围的排课信息
            weekCalculatorMapper.cancelWeeklySchedual(weekStart, weekEnd);
            blnstatus = true;
        } else {
            blnstatus = false;
        }
       
        return blnstatus;
    }

    @Override
    public KnPianoBean getInfoById(String id) {
        throw new UnsupportedOperationException("Unimplemented method 'getInfoById'");
    }

    // 看课程表（t_info_lesson）里有没有已经签到了的记录如果有，返回false，表示不可以撤销；如果没有，返回true，表示可以撤销
    private boolean isCancelbale(String startDate, String endDate) {
        return weekCalculatorMapper.checkLsnHasSignedOrNot(startDate,endDate).size() == 0;
    }
}