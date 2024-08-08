package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

import com.liu.springboot04web.bean.Kn03D001StuBean;
public interface Kn03D001StuMapper {
    
    public List<Kn03D001StuBean> getInfoList();

    List<Kn03D001StuBean> searchStudents(@Param("params") Map<String, Object> queryparams);

    public Kn03D001StuBean getInfoById(String id);

    public void updateInfo(Kn03D001StuBean bean);

    public void insertInfo(Kn03D001StuBean bean);

    public void deleteInfo(String id);

    // DBプロシージャを行う
    public void callProcedure(Map<String, Integer> map);
    // DB関数を行う
    public void getNextSequence(Map<String, Object> map);

}