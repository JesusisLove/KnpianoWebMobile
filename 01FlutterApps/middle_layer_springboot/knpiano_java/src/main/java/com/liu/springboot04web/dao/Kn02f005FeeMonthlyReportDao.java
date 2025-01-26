package com.liu.springboot04web.dao;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn02f005FeeMonthlyReportBean;
import com.liu.springboot04web.mapper.Kn02f005FeeMonthlyReportMapper;

@Repository
public class Kn02f005FeeMonthlyReportDao {

    @Autowired
    private Kn02f005FeeMonthlyReportMapper kn02f005Mapper;

    public List<Kn02f005FeeMonthlyReportBean> getInfoList(String year) {
    List<Kn02f005FeeMonthlyReportBean> list = kn02f005Mapper.getInfoList(year);
    return list;
    }

    public List<Kn02f005FeeMonthlyReportBean> getUnpaidInfo(String yearMonth) {
    List<Kn02f005FeeMonthlyReportBean> list = kn02f005Mapper.getUnpaidInfo(yearMonth);
    return list;
    }
}
