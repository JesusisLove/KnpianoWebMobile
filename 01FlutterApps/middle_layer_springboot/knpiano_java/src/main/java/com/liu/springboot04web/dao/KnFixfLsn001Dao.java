package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnFixfLsn001Bean;
import com.liu.springboot04web.mapper.KnFixfLsn001Mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class KnFixfLsn001Dao implements BzlFudousanDao {

    @Autowired
    private KnFixfLsn001Mapper knFixfLsn001Mapper;

    // 获取所有固定授業計画的信息列表
    public List<KnFixfLsn001Bean> getInfoList() {
        List<KnFixfLsn001Bean> list = knFixfLsn001Mapper.getInfoList();
        // System.out.println("查询的固定授業計画管理数据：" + list.toString());
        return list;
    }

    // 获取所有符合查询条件的学生信息
    public List<KnFixfLsn001Bean> searchFixedLessons(Map<String, Object> params) {
        return knFixfLsn001Mapper.searchFixedLessons(params);
    }

    // 根据ID获取银行信息
    public KnFixfLsn001Bean getInfoById(String id) {
        KnFixfLsn001Bean knBnk001Bean = knFixfLsn001Mapper.getInfoById(id);
        return knBnk001Bean;
   }

    // 根据ID获取特定的固定授業計画信息
    public KnFixfLsn001Bean getInfoByKey(String stuId, String subjectId, String fixedWeek) {
        KnFixfLsn001Bean knFixfLsn001Bean = knFixfLsn001Mapper.getInfoById(stuId, subjectId, fixedWeek);
        // System.out.println("查询的固定授業計画管理详细数据：" + knFixfLsn001Bean.toString());
        return knFixfLsn001Bean;
    }

    // 保存或更新固定授業計画信息
    public void save(KnFixfLsn001Bean knFixfLsn001Bean) {

        // 确认表里有没有记录，没有就insert，有记录就update
        if (getInfoByKey(knFixfLsn001Bean.getStuId(), knFixfLsn001Bean.getSubjectId(), knFixfLsn001Bean.getFixedWeek()) == null) {
            insert(knFixfLsn001Bean);
        } else {
            update(knFixfLsn001Bean);
        }
    } 

    // 删除固定授業計画信息
    public void deleteByKeys(String stuId, String subjectId, String fixedWeek) {
        knFixfLsn001Mapper.deleteInfoByKeys(stuId, subjectId, fixedWeek);
    }

    // 新增固定授業計画信息
    private void insert(KnFixfLsn001Bean knFixfLsn001Bean) {
        // System.out.println("插入的固定授業計画管理数据：" + knFixfLsn001Bean.toString());
        knFixfLsn001Mapper.insertInfo(knFixfLsn001Bean);
    }

    // 更新固定授業計画信息
    private void update(KnFixfLsn001Bean knFixfLsn001Bean) {
        // System.out.println("更新的固定授業計画管理数据：" + knFixfLsn001Bean.toString());
        knFixfLsn001Mapper.updateInfo(knFixfLsn001Bean);
    }
}
