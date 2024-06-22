package com.liu.springboot04web.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;

import com.liu.springboot04web.bean.Kn05S003SubjectEdabnBean;
public interface Kn05S003SubEdaBanMapper  {

    // 后台维护查询用
    public List<Kn05S003SubjectEdabnBean> getInfoList();
    
    // 手机端查询用
    public List<Kn05S003SubjectEdabnBean> getSubEdaList(@Param("subId")String subId);

    public Kn05S003SubjectEdabnBean getInfoById(@Param("subId")String subId, 
                                                @Param("edabanId") String edabanId);

    // 根据特定条模糊检索学生档案信息
    public List<Kn05S003SubjectEdabnBean> searchEdaSubject(@Param("params") Map<String, Object> queryparams);
                                                
    public void updateInfo(Kn05S003SubjectEdabnBean bean);
    public void insertInfo(Kn05S003SubjectEdabnBean bean);
    public void deleteInfo(@Param("subId")String subId, 
                           @Param("edabanId") String edabanId);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

}
