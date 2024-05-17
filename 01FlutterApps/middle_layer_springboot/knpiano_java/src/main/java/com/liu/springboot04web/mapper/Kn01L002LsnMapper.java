package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn01L002LsnBean;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
public interface Kn01L002LsnMapper  {

    public List<Kn01L002LsnBean> getInfoList();

    // 获取所有学生最新正在上课的科目信息
    public List<Kn01L002LsnBean>  getLatestSubjectList();

    public Kn01L002LsnBean getInfoById(String id);

    List<Kn01L002LsnBean> searchLessons(@Param("params") Map<String, Object> queryparams);

    public void updateInfo(Kn01L002LsnBean bean);

    public void insertInfo(Kn01L002LsnBean bean);

    public void deleteInfo(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

}