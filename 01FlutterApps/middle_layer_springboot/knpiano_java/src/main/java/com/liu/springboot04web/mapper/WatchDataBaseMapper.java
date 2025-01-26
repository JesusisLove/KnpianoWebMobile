package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.WatchDataBaseBean;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;


public interface WatchDataBaseMapper {

    public List<WatchDataBaseBean> searcSpExecutionLog(@Param("params") Map<String, Object> params);
    public void deleteAll();

}
