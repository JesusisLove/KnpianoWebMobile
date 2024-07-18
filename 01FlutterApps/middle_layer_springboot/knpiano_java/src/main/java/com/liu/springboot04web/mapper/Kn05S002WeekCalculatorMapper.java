package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.liu.springboot04web.bean.Kn05S002FixedLsnStatusBean;
import java.util.List;

@Mapper
public interface Kn05S002WeekCalculatorMapper {
    public List<Kn05S002FixedLsnStatusBean> getInfoList();
    void insertFixedLessonStatus(Kn05S002FixedLsnStatusBean status);
    public void deleteAll();
}