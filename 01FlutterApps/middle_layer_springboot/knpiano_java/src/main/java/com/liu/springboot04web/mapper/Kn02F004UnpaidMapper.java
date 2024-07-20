package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F004UnpaidBean;
public interface Kn02F004UnpaidMapper  {

    public List<Kn02F004UnpaidBean> searchLsnUnpay(@Param("params") Map<String, Object> params);
    public Kn02F004UnpaidBean getLsnUnpayByID(@Param("lsnFeeId") String lsnFeeId);
    public void updateInfo(Kn02F004UnpaidBean bean);
    public void insertInfo(Kn02F004UnpaidBean bean);
    public void deleteInfo(@Param("lsnPayId") String lsnPayId, 
                           @Param("lsnFeeId") String LsnFeeId);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

} 