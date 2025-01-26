package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.WatchDataBaseBean;
import com.liu.springboot04web.mapper.WatchDataBaseMapper;

import java.util.List;
import java.util.Map;

@Repository
public class WatchDataBaseDao {

    @Autowired
    private WatchDataBaseMapper watchDataBaseMapper;

    // 取得执行存储过程的日志消息
    public List<WatchDataBaseBean> searcSpExecutionLog(Map<String, Object> params) {

        List<WatchDataBaseBean> list = watchDataBaseMapper.searcSpExecutionLog(params);

        return list;
    }

    // 删除所有存储过程的日志消息
    public void deleteAll() {
        watchDataBaseMapper.deleteAll();
    }
    

}
