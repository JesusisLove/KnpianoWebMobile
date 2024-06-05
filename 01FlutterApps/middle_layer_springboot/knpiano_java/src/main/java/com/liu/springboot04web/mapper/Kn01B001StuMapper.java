package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

import com.liu.springboot04web.bean.Kn01B001StuBean;
public interface Kn01B001StuMapper {
    
    public List<Kn01B001StuBean> getInfoList();

    List<Kn01B001StuBean> searchStudents(@Param("params") Map<String, Object> queryparams);

    public Kn01B001StuBean getInfoById(String id);

    public void updateInfo(Kn01B001StuBean bean);

    public void insertInfo(Kn01B001StuBean bean);

    public void deleteInfo(String id);

    // DBプロシージャを行う
    public void callProcedure(Map<String, Integer> map);
    // DB関数を行う
    public void getNextSequence(Map<String, Object> map);

}