package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn02f005FeeMonthlyReportBean;

import java.util.List;

import org.springframework.data.repository.query.Param;

public interface Kn02f005FeeMonthlyReportMapper {
    public List<Kn02f005FeeMonthlyReportBean> getInfoList(@Param("year") String year);
    public List<Kn02f005FeeMonthlyReportBean> getUnpaidInfo(@Param("yearMonth") String yearMonth);

}
