package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

import com.liu.springboot04web.bean.KnSub001Bean;

public interface KnSub001Mapper {

    public List<KnSub001Bean> getInfoList();

    List<KnSub001Bean> searchSubjects(@Param("params") Map<String, Object> queryparams);

    public KnSub001Bean getInfoById(String id);

    public void insertInfo(KnSub001Bean bean);

    public void updateInfo(KnSub001Bean bean);

    public void deleteInfo(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}