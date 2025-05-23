package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

import com.liu.springboot04web.bean.Kn03D002SubBean;

public interface Kn03D002SubMapper {

    public List<Kn03D002SubBean> getInfoList();

    List<Kn03D002SubBean> searchSubjects(@Param("params") Map<String, Object> queryparams);

    public Kn03D002SubBean getInfoById(String id);

    public void insertInfo(Kn03D002SubBean bean);

    public void updateInfo(Kn03D002SubBean bean);

    public void deleteInfo(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}