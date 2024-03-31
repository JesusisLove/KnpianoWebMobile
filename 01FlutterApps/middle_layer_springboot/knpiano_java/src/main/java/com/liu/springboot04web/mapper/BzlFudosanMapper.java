package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.BzlFudousanBean;

import java.util.List;
import java.util.Map;

public interface BzlFudosanMapper {

    public List<?> getInfoList();
    public BzlFudousanBean getInfoById(String id);

    //查询存储过程的方法
    public void callProcedure(Map map);

    //查询函数的方法:
    public void getNextSequence(Map map);
}