package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn03D003BnkBean;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface Kn03D003BnkMapper {

    List<Kn03D003BnkBean> getInfoList();

    /* 画面检索 检索功能追加  开始 */ 
    List<Kn03D003BnkBean> searchBanks(@Param("params") Map<String, Object> queryparams);
    /* 画面检索 检索功能追加  开始 */ 

    Kn03D003BnkBean getInfoById(String id);

    void insertInfo(Kn03D003BnkBean bean);

    void updateInfo(Kn03D003BnkBean bean);

    void deleteInfo(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}
