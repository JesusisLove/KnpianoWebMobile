package com.liu.springboot04web.dao;

import java.util.List;

import org.springframework.data.repository.query.Param;

import com.liu.springboot04web.bean.Kn04I004BatchLsnSignBean;

public interface Kn04I004BatchLsnSignDao {

    public List<Kn04I004BatchLsnSignBean> getWeeksForYear();

    public List<Kn04I004BatchLsnSignBean> getLsnScheOfWeek(@Param("startWeek") String startWeek,
                                                           @Param("endWeek")   String endWeek);
    // Web页面【前一周】【下一周】按钮按下
    public Kn04I004BatchLsnSignBean getLsnScheOfWeekByWeekNumber(@Param("weekNum") String weekNum);
    
}
