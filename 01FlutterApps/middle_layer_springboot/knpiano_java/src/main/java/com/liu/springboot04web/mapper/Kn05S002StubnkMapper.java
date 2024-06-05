package com.liu.springboot04web.mapper;


import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import com.liu.springboot04web.bean.Kn05S002StubnkBean;

public interface Kn05S002StubnkMapper {

    public List<Kn05S002StubnkBean> getInfoList();
    public Kn05S002StubnkBean getInfoById(@Param("id")String id);
    public void updateInfo(Kn05S002StubnkBean bean);
    public void insertInfo(Kn05S002StubnkBean bean);
    public void deleteInfo(@Param("id")String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}
