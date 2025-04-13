package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.KnPianoBean;

import java.util.List;
import java.util.Map;

public interface KnPianoMapper {

    public List<?> getInfoList();
    public KnPianoBean getInfoById(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}