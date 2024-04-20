package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.bean.KnSutdoc001Bean;
import com.liu.springboot04web.mapper.KnSub001Mapper;
import com.liu.springboot04web.mapper.KnSutdoc001Mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Date;
// import java.sql.Date;

@Repository
public class KnSutdoc001Dao implements InterfaceKnPianoDao {

    @Autowired
    private KnSutdoc001Mapper knSutdoc001Mapper;

    // 获取所有学生档案信息的信息列表
    public List<KnSutdoc001Bean> getInfoList() {
        List<KnSutdoc001Bean> list = knSutdoc001Mapper.getInfoList();
        // System.out.println("查询的学生档案信息管理数据：" + list.toString());
        return list;
    }

    // 获取所有符合查询条件的学生档案信息
    public List<KnSutdoc001Bean> searchStuDoc(Map<String, Object> params) {
        return knSutdoc001Mapper.searchStuDoc(params);
    }

    // 根据ID获取信息(该方法不使用，为什么不删除？因为implements InterfaceKnPianoDao)
    public KnSutdoc001Bean getInfoById(String id) {
        return null;
   }

    // 根据ID获取特定的学生档案信息信息
    public KnSutdoc001Bean getInfoByKey(String stuId, String subjectId, Date adjustedDate) {
        KnSutdoc001Bean knSutdoc001Bean = knSutdoc001Mapper.getInfoByKey(stuId, subjectId, adjustedDate);
        // System.out.println("查询的学生档案信息管理详细数据：" + knSutdoc001Bean.toString());
        return knSutdoc001Bean;
    }

    // 保存或更新学生档案信息信息
    public void save(KnSutdoc001Bean knSutdoc001Bean) {

        // 确认表里有没有记录，没有就insert，有记录就update
        if (getInfoByKey(knSutdoc001Bean.getStuId(), knSutdoc001Bean.getSubjectId(), knSutdoc001Bean.getAdjustedDate()) == null) {
            insert(knSutdoc001Bean);
        } else {
            update(knSutdoc001Bean);
        }
    } 

    // 删除学生档案信息信息
    public void deleteByKeys(String stuId, String subjectId, Date adjustedDate) {
        knSutdoc001Mapper.deleteInfoByKeys(stuId, subjectId, adjustedDate);
    }

    // 新增学生档案信息信息
    private void insert(KnSutdoc001Bean knSutdoc001Bean) {
        // System.out.println("插入的学生档案信息管理数据：" + knSutdoc001Bean.toString());
        knSutdoc001Mapper.insertInfo(knSutdoc001Bean);
    }

    // 更新学生档案信息信息
    private void update(KnSutdoc001Bean knSutdoc001Bean) {
        // System.out.println("更新的学生档案信息管理数据：" + knSutdoc001Bean.toString());
        knSutdoc001Mapper.updateInfo(knSutdoc001Bean);
    }
}
