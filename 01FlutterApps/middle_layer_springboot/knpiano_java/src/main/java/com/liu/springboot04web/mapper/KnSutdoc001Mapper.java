package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.KnSutdoc001Bean;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
import java.util.Date;
public interface KnSutdoc001Mapper  {

    public List<KnSutdoc001Bean> getInfoList();
    
    // 根据特定条模糊检索学生档案信息
    public List<KnSutdoc001Bean> searchStuDoc(@Param("params") Map<String, Object> queryparams);

    public KnSutdoc001Bean getInfoByKey(@Param("stuId") String stuId, 
                                        @Param("subjectId") String subjectId, 
                                        @Param("adjustedDate") Date adjustedDate);

    public void updateInfo(KnSutdoc001Bean bean);

    public void insertInfo(KnSutdoc001Bean bean);

    public void deleteInfoByKeys(@Param("stuId") String stuId, 
                                  @Param("subjectId") String subjectId, 
                                  @Param("adjustedDate") Date adjustedDate);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

}