package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn03D002StuDocBean;
import com.liu.springboot04web.mapper.Kn03D002StuDocMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Date;

@Repository
public class Kn03D002StuDocDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn03D002StuDocMapper knStudoc001Mapper;

    // 获取所有学生档案信息的信息列表
    public List<Kn03D002StuDocBean> getInfoList() {
        List<Kn03D002StuDocBean> list = knStudoc001Mapper.getInfoList();
        return list;
    }

    // 还未建档的学生姓名取得
    public List<Kn03D002StuDocBean> getUnDocedList() {
        List<Kn03D002StuDocBean> list = knStudoc001Mapper.getUnDocedList();
        return list;
    }
    
    // 获取所有符合查询条件的学生档案信息
    public List<Kn03D002StuDocBean> searchStuDoc(Map<String, Object> params) {
        return knStudoc001Mapper.searchStuDoc(params);
    }

    // 根据ID获取信息(该方法不使用，为什么不删除？因为implements InterfaceKnPianoDao)
    public Kn03D002StuDocBean getInfoById(String id) {
        return null;
   }

    // 根据ID获取特定的学生档案信息信息
    public Kn03D002StuDocBean getInfoByKey(String stuId, String subjectId, String subjectSubId, Date adjustedDate) {
        
        Kn03D002StuDocBean knStudoc001Bean = knStudoc001Mapper.getInfoByKey(stuId, subjectId, subjectSubId, adjustedDate);
        return knStudoc001Bean;
    }

    // 保存或更新学生档案信息信息
    public void save(Kn03D002StuDocBean knStudoc001Bean, boolean addNewMode) {

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
    private void insert(Kn03D002StuDocBean knStudoc001Bean) {
        knStudoc001Mapper.insertInfo(knStudoc001Bean);
    }

    // 更新学生档案信息信息
    private void update(Kn03D002StuDocBean knStudoc001Bean) {
        knStudoc001Mapper.updateInfo(knStudoc001Bean);
    }

    // 从学生档案表里，取得该生当前科目最新的价格信息
    public Kn03D002StuDocBean getLsnPrice(String stuId, 
                                          String subjectId,
                                          String subjectSubId) {
        return knStudoc001Mapper.getLsnPrice(stuId, subjectId, subjectSubId);
    }

    // 获取所有学生最新正在上课的科目信息
    public List<Kn03D002StuDocBean> getLatestSubjectList() {
        List<Kn03D002StuDocBean> list = knStudoc001Mapper.getLatestSubjectList();
        return list;
    }
}
