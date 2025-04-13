package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn03D002SubEdaBanBean;
public interface Kn03D002SubEdaBanMapper  {

    // 后台维护查询用
    public List<Kn03D002SubEdaBanBean> getInfoList();
    
    // 手机端查询用
    public List<Kn03D002SubEdaBanBean> getSubEdaList(@Param("subId")String subId);

    public Kn03D002SubEdaBanBean getInfoById(@Param("subId")String subId, 
                                                @Param("edabanId") String edabanId);

    // 根据特定条模糊检索学生档案信息
    public List<Kn03D002SubEdaBanBean> searchEdaSubject(@Param("params") Map<String, Object> queryparams);
                                                
    public void updateInfo(Kn03D002SubEdaBanBean bean);
    public void insertInfo(Kn03D002SubEdaBanBean bean);
    public void deleteInfo(@Param("subId")String subId, 
                           @Param("edabanId") String edabanId);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

}
