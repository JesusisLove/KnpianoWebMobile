package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.KnLsn001Bean;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
public interface KnLsn001Mapper  {

    public List<KnLsn001Bean> getInfoList();

    // 获取所有学生最新正在上课的科目信息
    public List<KnLsn001Bean>  getLatestSubjectList();

    public KnLsn001Bean getInfoById(String id);

    List<KnLsn001Bean> searchLessons(@Param("params") Map<String, Object> queryparams);

    public void updateInfo(KnLsn001Bean bean);

    public void insertInfo(KnLsn001Bean bean);

    public void deleteInfo(String id);

    // DBプロシージャを行う
    public void callProcedure(Map map);
    // DB関数を行う
    public void getNextSequence(Map map);

}