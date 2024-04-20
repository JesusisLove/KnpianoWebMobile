package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnStudoc001Bean;
import com.liu.springboot04web.mapper.KnStudoc001Mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Date;

@Repository
public class KnStudoc001Dao implements InterfaceKnPianoDao {

    @Autowired
    private KnStudoc001Mapper knStudoc001Mapper;

    // 获取所有学生档案信息的信息列表
    public List<KnStudoc001Bean> getInfoList() {
        List<KnStudoc001Bean> list = knStudoc001Mapper.getInfoList();
        // System.out.println("查询的学生档案信息管理数据：" + list.toString());
        return list;
    }

    // 获取所有符合查询条件的学生档案信息
    public List<KnStudoc001Bean> searchStuDoc(Map<String, Object> params) {
        return knStudoc001Mapper.searchStuDoc(params);
    }

    // 根据ID获取信息(该方法不使用，为什么不删除？因为implements InterfaceKnPianoDao)
    public KnStudoc001Bean getInfoById(String id) {
        return null;
   }

    // 根据ID获取特定的学生档案信息信息
    public KnStudoc001Bean getInfoByKey(String stuId, String subjectId, Date adjustedDate) {
        KnStudoc001Bean knStudoc001Bean = knStudoc001Mapper.getInfoByKey(stuId, subjectId, adjustedDate);
        // System.out.println("查询的学生档案信息管理详细数据：" + knStudoc001Bean.toString());
        return knStudoc001Bean;
    }

    // 保存或更新学生档案信息信息
    public void save(KnStudoc001Bean knStudoc001Bean) {

        // 确认表里有没有记录，没有就insert，有记录就update
        if (getInfoByKey(knStudoc001Bean.getStuId(), knStudoc001Bean.getSubjectId(), knStudoc001Bean.getAdjustedDate()) == null) {
            insert(knStudoc001Bean);
        } else {
            update(knStudoc001Bean);
        }
    } 

    // 删除学生档案信息信息
    public void deleteByKeys(String stuId, String subjectId, Date adjustedDate) {
        knStudoc001Mapper.deleteInfoByKeys(stuId, subjectId, adjustedDate);
    }

    // 新增学生档案信息信息
    private void insert(KnStudoc001Bean knStudoc001Bean) {
        // System.out.println("插入的学生档案信息管理数据：" + knStudoc001Bean.toString());
        knStudoc001Mapper.insertInfo(knStudoc001Bean);
    }

    // 更新学生档案信息信息
    private void update(KnStudoc001Bean knStudoc001Bean) {
        // System.out.println("更新的学生档案信息管理数据：" + knStudoc001Bean.toString());
        knStudoc001Mapper.updateInfo(knStudoc001Bean);
    }
}
