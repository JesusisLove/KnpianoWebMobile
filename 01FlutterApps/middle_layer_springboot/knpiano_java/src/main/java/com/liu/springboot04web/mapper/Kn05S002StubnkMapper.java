package com.liu.springboot04web.mapper;


import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import com.liu.springboot04web.bean.Kn05S002StubnkBean;

public interface Kn05S002StubnkMapper {

    public List<Kn05S002StubnkBean> getInfoList();
    public List<Kn05S002StubnkBean> getInfoByStuId(@Param("stuId")String stuId);
    public Kn05S002StubnkBean getInfoByStuIdBnkId(@Param("stuId")String stuId, @Param("bankId")String bankId);
    public List<Kn05S002StubnkBean> searchStuBank(@Param("params") Map<String, Object> queryparams);
    public void updateInfo(Kn05S002StubnkBean bean);
    public void insertInfo(Kn05S002StubnkBean bean);
    public void deleteInfo(@Param("id")String id);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}
