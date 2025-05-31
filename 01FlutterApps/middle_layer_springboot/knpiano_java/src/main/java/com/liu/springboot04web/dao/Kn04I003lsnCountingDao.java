package com.liu.springboot04web.dao;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn04I003LsnCountingBean;

public interface Kn04I003lsnCountingDao {
     public List<Kn04I003LsnCountingBean> getStuLsnCount(@Param("year_month_from")String yearMonthFrom, 
                                                         @Param("year_month_to")String yearMonthTo );

}