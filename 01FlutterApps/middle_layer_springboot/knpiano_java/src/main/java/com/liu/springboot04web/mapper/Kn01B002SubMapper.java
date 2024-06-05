package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

import com.liu.springboot04web.bean.Kn01B002SubBean;

public interface Kn01B002SubMapper {

    public List<Kn01B002SubBean> getInfoList();

    List<Kn01B002SubBean> searchSubjects(@Param("params") Map<String, Object> queryparams);

    public Kn01B002SubBean getInfoById(String id);

    public void insertInfo(Kn01B002SubBean bean);

    public void updateInfo(Kn01B002SubBean bean);

    public void deleteInfo(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}