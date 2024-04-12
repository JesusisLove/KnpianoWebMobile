package com.liu.springboot04web.mapper;

import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

import com.liu.springboot04web.bean.KnStu001Bean;
public interface KnStu001Mapper {
    
    public List<KnStu001Bean> getInfoList();

    List<KnStu001Bean> searchStudents(@Param("params") Map<String, Object> queryparams);

    public KnStu001Bean getInfoById(String id);

    public void updateInfo(KnStu001Bean bean);

    public void insertInfo(KnStu001Bean bean);

    public void deleteInfo(String id);

    // DBプロシージャを行う
    public void callProcedure(Map map);
    // DB関数を行う
    public void getNextSequence(Map map);

}