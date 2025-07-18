package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.mapper.Kn03D004StuDocMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Date;

@Repository
public class Kn03D004StuDocDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn03D004StuDocMapper knStudoc001Mapper;

    // 获取所有学生档案信息的信息列表：后台维护使用
    public List<Kn03D004StuDocBean> getInfoList() {
        List<Kn03D004StuDocBean> list = knStudoc001Mapper.getInfoList();
        return list;
    }

    // 手机端网页提取已经入档的学生名单
    public List<Kn03D004StuDocBean> getDocedStuList() {
        List<Kn03D004StuDocBean> list = knStudoc001Mapper.getDocedStuList();
        return list;
    }

    // 还未建档的学生姓名取得
    public List<Kn03D004StuDocBean> getUnDocedList() {
        List<Kn03D004StuDocBean> list = knStudoc001Mapper.getUnDocedList();
        return list;
    }

    // 手机端网页提取已经入档的学生他本人的历史档案信息 
    public List<Kn03D004StuDocBean> getDocedstuDetailList(String stuId) {
        List<Kn03D004StuDocBean> list = knStudoc001Mapper.getDocedstuDetailList(stuId);
        return list;
    }

    
    // 获取所有符合查询条件的学生档案信息
    public List<Kn03D004StuDocBean> searchStuDoc(Map<String, Object> params) {
        return knStudoc001Mapper.searchStuDoc(params);
    }

    // 根据ID获取信息(该方法不使用，为什么不删除？因为implements InterfaceKnPianoDao)
    public Kn03D004StuDocBean getInfoById(String id) {
        return null;
   }

    // 根据ID获取特定的学生档案信息信息
    public Kn03D004StuDocBean getInfoByKey(String stuId, String subjectId, String subjectSubId, Date adjustedDate) {
        
        Kn03D004StuDocBean knStudoc001Bean = knStudoc001Mapper.getInfoByKey(stuId, subjectId, subjectSubId, adjustedDate);
        return knStudoc001Bean;
    }

    // 保存或更新学生档案信息信息
    public void save(Kn03D004StuDocBean knStudoc001Bean, boolean addNewMode) {

        if (addNewMode) {
            insert(knStudoc001Bean);
        } else {
            update(knStudoc001Bean);
        }
    } 

    // 删除学生档案信息信息
    public void deleteByKeys(String stuId, String subjectId, String subjectSubId, Date adjustedDate) {
        knStudoc001Mapper.deleteInfoByKeys(stuId, subjectId, subjectSubId, adjustedDate);
    }

    // 新增学生档案信息信息
    private void insert(Kn03D004StuDocBean knStudoc001Bean) {
        knStudoc001Mapper.insertInfo(knStudoc001Bean);
    }

    // 更新学生档案信息信息
    private void update(Kn03D004StuDocBean knStudoc001Bean) {
        knStudoc001Mapper.updateInfo(knStudoc001Bean);
    }

    // 从学生档案表里，取得该生当前科目最新的价格信息
    public Kn03D004StuDocBean getLsnPrice(String stuId, 
                                          String subjectId,
                                          String subjectSubId) {
        return knStudoc001Mapper.getLsnPrice(stuId, subjectId, subjectSubId);
    }

    // 获取所有学生最新正在上课的科目信息
    public List<Kn03D004StuDocBean> getLatestSubjectList() {
        List<Kn03D004StuDocBean> list = knStudoc001Mapper.getLatestSubjectList();
        return list;
    }

    // 获取所有学生最新正在上课的科目信息
    public Kn03D004StuDocBean getLatestMinAdjustDateByStuId(String stuId, String subjectId) {
        Kn03D004StuDocBean list = knStudoc001Mapper.getLatestMinAdjustDateByStuId(stuId, subjectId);
        return list;
    }

    // 手机前端添加课程的排课画面：从学生档案表视图中取得该学生正在上的所有科目信息
    public List<Kn03D004StuDocBean>  getLatestSubjectListByStuId(String stuId) {
        List<Kn03D004StuDocBean> list = knStudoc001Mapper.getLatestSubjectListByStuId(stuId);
        return list;
    }
}
