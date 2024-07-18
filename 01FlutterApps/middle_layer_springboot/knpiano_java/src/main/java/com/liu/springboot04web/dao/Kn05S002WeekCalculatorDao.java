package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.WeekFields;
import java.util.List;
import java.util.Locale;

import com.liu.springboot04web.bean.Kn05S002FixedLsnStatusBean;
import com.liu.springboot04web.bean.KnPianoBean;
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

    @Override
    public KnPianoBean getInfoById(String id) {
        throw new UnsupportedOperationException("Unimplemented method 'getInfoById'");
    }
}