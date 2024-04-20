package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.KnStudoc001Bean;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
import java.util.Date;
public interface KnStudoc001Mapper  {

    public List<KnStudoc001Bean> getInfoList();
    
    // 根据特定条模糊检索学生档案信息
    public List<KnStudoc001Bean> searchStuDoc(@Param("params") Map<String, Object> queryparams);

    public KnStudoc001Bean getInfoByKey(@Param("stuId") String stuId, 
                                        @Param("subjectId") String subjectId, 
                                        @Param("adjustedDate") Date adjustedDate);

    public void updateInfo(KnStudoc001Bean bean);

    public void insertInfo(KnStudoc001Bean bean);

    public void deleteInfoByKeys(@Param("stuId") String stuId, 
                                  @Param("subjectId") String subjectId, 
                                  @Param("adjustedDate") Date adjustedDate);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

}