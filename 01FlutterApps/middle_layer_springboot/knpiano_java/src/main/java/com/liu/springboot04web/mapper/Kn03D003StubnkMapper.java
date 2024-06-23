package com.liu.springboot04web.mapper;


import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Param;
import com.liu.springboot04web.bean.Kn03D003StubnkBean;

public interface Kn03D003StubnkMapper {

    public List<Kn03D003StubnkBean> getInfoList();
    public List<Kn03D003StubnkBean> getInfoByStuId(@Param("stuId")String stuId);
    public Kn03D003StubnkBean getInfoByStuIdBnkId(@Param("stuId")String stuId, @Param("bankId")String bankId);
    public List<Kn03D003StubnkBean> searchStuBank(@Param("params") Map<String, Object> queryparams);
    public void updateInfo(Kn03D003StubnkBean bean);
    public void insertInfo(Kn03D003StubnkBean bean);
    public void deleteInfo(@Param("stuId")String stuId, @Param("bankId")String bankId);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);
}
