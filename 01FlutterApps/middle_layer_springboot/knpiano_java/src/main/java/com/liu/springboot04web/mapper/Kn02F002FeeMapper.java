package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn02F002FeeBean;
public interface Kn02F002FeeMapper  {

    public List<Kn02F002FeeBean> getInfoList();
    public List<Kn02F002FeeBean> searchLsnFee(@Param("params") Map<String, Object> queryparams);
    public Kn02F002FeeBean       getInfoById(String lsnFeeId, String lessonId);
    public List<Kn02F002FeeBean> checkScheLsnCurrentMonth(@Param("stuId")      String  stuId,
                                                          @Param("subjectId")  String  subjectId, 
                                                          @Param("lessonType") Integer lessonType,
                                                          @Param("lsnMonth")   String  lsnMonth);
    public void updateInfo(Kn02F002FeeBean bean);
    public void insertInfo(Kn02F002FeeBean bean);
    public void deleteInfo(String lsnFeeId, String lessonId);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

}
