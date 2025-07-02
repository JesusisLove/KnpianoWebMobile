package com.liu.springboot04web.mapper;

import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import org.apache.ibatis.annotations.Param;
import java.util.List;
import java.util.Map;
import java.util.Date;
public interface Kn03D004StuDocMapper  {

    public List<Kn03D004StuDocBean> getInfoList();

    // 手机端网页提取已经入档的学生名单
    public List<Kn03D004StuDocBean> getDocedStuList();
    
    // 根据特定条模糊检索学生档案信息
    public List<Kn03D004StuDocBean> searchStuDoc(@Param("params") Map<String, Object> queryparams);

    // 还未建档的学生姓名取得
    public List<Kn03D004StuDocBean> getUnDocedList();

    // 手机端网页提取已经入档的学生他本人的历史档案信息 
    public List<Kn03D004StuDocBean> getDocedstuDetailList(@Param("stuId") String stuId);


    public Kn03D004StuDocBean getInfoByKey(@Param("stuId") String stuId, 
                                           @Param("subjectId") String subjectId, 
                                           @Param("subjectSubId") String subjectSubId,
                                           @Param("adjustedDate") Date adjustedDate);

    // 后台维护，获取suo有学生最新正在上的科目信息
    public List<Kn03D004StuDocBean> getLatestSubjectList();

    // 手机前端添加课程的排课画面：从学生档案表视图中取得该学生正在上的所有科目信息
    public List<Kn03D004StuDocBean> getLatestSubjectListByStuId(@Param("stuId") String stuId);

    // 手机前端添加课程的排课画面：排课点击保存按钮时，验证该日期的排课是否时有效的排课
    // 何为有效排课：学生档案第一次调整日期以后的日期都是有效排课，第一次调整日期以前的排课是无效排课
    // 就好像，你还没出生就上学了，这是不合理的
    public Kn03D004StuDocBean getLatestMinAdjustDateByStuId(@Param("stuId") String stuId, @Param("subjectId") String subjectId);

    public void updateInfo(Kn03D004StuDocBean bean);

    public void insertInfo(Kn03D004StuDocBean bean);

    public void deleteInfoByKeys(@Param("stuId") String stuId, 
                                 @Param("subjectId") String subjectId, 
                                 @Param("subjectSubId") String subjectSubId,
                                 @Param("adjustedDate") Date adjustedDate);

    // 执行数据库存储过程
    public void callProcedure(Map<String, Integer> map);
    
    // 获取下一个序列值
    public void getNextSequence(Map<String, Object> map);

    // 从学生档案表里，取得该生当前科目最新的价格信息
    public Kn03D004StuDocBean getLsnPrice(@Param("stuId") String stuId, 
                                          @Param("subjectId") String subjectId,
                                          @Param("subjectSubId") String subjectSubId);

}