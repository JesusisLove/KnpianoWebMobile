package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.KnLsnPay001Bean;
public interface KnLsnPay001Mapper  {

    public List<KnLsnPay001Bean> getInfoList();
    public List<KnLsnPay001Bean> searchLsnPay(@Param("params") Map<String, Object> params);
    public KnLsnPay001Bean getInfoById(String lsnPayId, String lsnFeeId);
    public void updateInfo(KnLsnPay001Bean bean);
    public void insertInfo(KnLsnPay001Bean bean);
    public void deleteInfo(@Param("lsnPayId") String lsnPayId, 
                           @Param("lsnFeeId") String LsnFeeId);

    // DBプロシージャを行う
    public void callProcedure(Map map);
    // DB関数を行う
    public void getNextSequence(Map map);

} 