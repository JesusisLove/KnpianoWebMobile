package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.KnBnk001Bean;
import java.util.List;
import java.util.Map;

public interface KnBnk001Mapper {

    List<KnBnk001Bean> getInfoList();

    KnBnk001Bean getInfoById(String id);

    void insertInfo(KnBnk001Bean bean);

    void updateInfo(KnBnk001Bean bean);

    void deleteInfo(String id);

    // 执行数据库存储过程
    void callProcedure(Map<String, Object> map);

    // 获取下一个序列值
    void getNextSequence(Map<String, Object> map);
}
