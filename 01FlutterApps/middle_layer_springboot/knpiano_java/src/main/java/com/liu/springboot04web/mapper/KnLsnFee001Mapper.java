package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.KnLsnFee001Bean;
public interface KnLsnFee001Mapper  {

    public List<KnLsnFee001Bean> getInfoList();
    public List<KnLsnFee001Bean> searchLsnFee(@Param("params") Map<String, Object> queryparams);
    public KnLsnFee001Bean getInfoById(String lsnFeeId, String lessonId);
    public void updateInfo(KnLsnFee001Bean bean);
    public void insertInfo(KnLsnFee001Bean bean);
    public void deleteInfo(String lsnFeeId, String lessonId);

    // DBプロシージャを行う
    public void callProcedure(Map map);
    // DB関数を行う
    public void getNextSequence(Map map);

}
