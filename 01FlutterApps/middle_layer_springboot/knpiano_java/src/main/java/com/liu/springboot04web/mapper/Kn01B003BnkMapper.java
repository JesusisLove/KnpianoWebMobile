package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn01B003BnkBean;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface Kn01B003BnkMapper {

    List<Kn01B003BnkBean> getInfoList();

    /* 画面检索 检索功能追加  开始 */ 
    List<Kn01B003BnkBean> searchBanks(@Param("params") Map<String, Object> queryparams);
    /* 画面检索 检索功能追加  开始 */ 

    Kn01B003BnkBean getInfoById(String id);

    void insertInfo(Kn01B003BnkBean bean);

    void updateInfo(Kn01B003BnkBean bean);

    void deleteInfo(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}
