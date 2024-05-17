package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn02F001BnkBean;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;

public interface Kn02F001BnkMapper {

    List<Kn02F001BnkBean> getInfoList();

    /* 画面检索 检索功能追加  开始 */ 
    List<Kn02F001BnkBean> searchBanks(@Param("params") Map<String, Object> queryparams);
    /* 画面检索 检索功能追加  开始 */ 

    Kn02F001BnkBean getInfoById(String id);

    void insertInfo(Kn02F001BnkBean bean);

    void updateInfo(Kn02F001BnkBean bean);

    void deleteInfo(String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}
