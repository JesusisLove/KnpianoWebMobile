package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F004PayBean;
public interface Kn02F004PayMapper  {

    public List<Kn02F004PayBean> getInfoList();
    public List<Kn02F004PayBean> searchLsnPay(@Param("params") Map<String, Object> params);
    public void deleteInfo(@Param("lsnPayId") String lsnPayId, 
                           @Param("lsnFeeId") String LsnFeeId);

    public List<Kn02F004PayBean> isHasMonthlyPaid(@Param("stuId")     String stuId,
                                                  @Param("subjectId") String subjectId,
                                                  @Param("payMonth")  String payMonth);
    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

} 