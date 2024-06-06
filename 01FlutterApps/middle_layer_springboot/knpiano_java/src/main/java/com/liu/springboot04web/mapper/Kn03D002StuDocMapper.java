package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn03D002StuDocBean;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
import java.util.Date;
public interface Kn03D002StuDocMapper  {

    public List<Kn03D002StuDocBean> getInfoList();
    
    // 根据特定条模糊检索学生档案信息
    public List<Kn03D002StuDocBean> searchStuDoc(@Param("params") Map<String, Object> queryparams);

    public Kn03D002StuDocBean getInfoByKey(@Param("stuId") String stuId, 
                                           @Param("subjectId") String subjectId, 
                                           @Param("subjectSubId") String subjectSubId,
                                           @Param("adjustedDate") Date adjustedDate);

    public List<Kn03D002StuDocBean> getLatestSubjectList();

    public void updateInfo(Kn03D002StuDocBean bean);

    public void insertInfo(Kn03D002StuDocBean bean);

    public void deleteInfoByKeys(@Param("stuId") String stuId, 
                                 @Param("subjectId") String subjectId, 
                                 @Param("subjectSubId") String subjectSubId,
                                 @Param("adjustedDate") Date adjustedDate);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

    // 从学生档案表里，取得该生当前科目最新的价格信息
    public Kn03D002StuDocBean getLsnPrice(@Param("stuId") String stuId, 
                                          @Param("subjectId") String subjectId);

}