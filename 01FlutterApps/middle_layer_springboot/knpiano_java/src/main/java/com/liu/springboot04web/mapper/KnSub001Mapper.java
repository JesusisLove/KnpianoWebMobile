package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import com.liu.springboot04web.bean.KnSub001Bean;

public interface KnSub001Mapper {

    public List<KnSub001Bean> getInfoList();

    public KnSub001Bean getInfoById(String id);

    public void insertInfo(KnSub001Bean bean);

    public void updateInfo(KnSub001Bean bean);

    public void deleteInfo(String id);

    // DBプロシージャを行う
    public void callProcedure(Map map);
    // DB関数を行う
    public void getNextSequence(Map map);
}