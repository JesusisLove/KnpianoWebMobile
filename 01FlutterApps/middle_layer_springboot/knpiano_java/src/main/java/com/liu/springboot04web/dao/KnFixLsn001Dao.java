package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnFixLsn001Bean;
import com.liu.springboot04web.mapper.KnFixLsn001Mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class KnFixLsn001Dao implements InterfaceKnPianoDao {

    @Autowired
    private KnFixLsn001Mapper knFixLsn001Mapper;

    // 获取所有固定授業計画的信息列表
    public List<KnFixLsn001Bean> getInfoList() {
        List<KnFixLsn001Bean> list = knFixLsn001Mapper.getInfoList();
        // System.out.println("查询的固定授業計画管理数据：" + list.toString());
        return list;
    }

    // 获取所有学生最新正在上课的科目信息
    public List<KnFixLsn001Bean> getLatestSubjectList() {
        List<KnFixLsn001Bean> list = knFixLsn001Mapper.getLatestSubjectList();
        return list;
    }

    // 获取所有符合查询条件的学生固定排课信息
    public List<KnFixLsn001Bean> searchFixedLessons(Map<String, Object> params) {
        return knFixLsn001Mapper.searchFixedLessons(params);
    }

    // 根据ID获取信息(该方法不使用，为什么不删除？因为implements InterfaceKnPianoDao)
    public KnFixLsn001Bean getInfoById(String id) {
        return null;
   }

    // 根据ID获取特定的固定授業計画信息
    public KnFixLsn001Bean getInfoByKey(String stuId, String subjectId, String fixedWeek) {
        KnFixLsn001Bean knFixLsn001Bean = knFixLsn001Mapper.getInfoById(stuId, subjectId, fixedWeek);
        // System.out.println("查询的固定授業計画管理详细数据：" + knFixLsn001Bean.toString());
        return knFixLsn001Bean;
    }

    // 保存或更新固定授業計画信息
    public void save(KnFixLsn001Bean knFixLsn001Bean) {

        // 确认表里有没有记录，没有就insert，有记录就update
        if (getInfoByKey(knFixLsn001Bean.getStuId(), knFixLsn001Bean.getSubjectId(), knFixLsn001Bean.getFixedWeek()) == null) {
            insert(knFixLsn001Bean);
        } else {
            update(knFixLsn001Bean);
        }
    } 

    // 删除固定授業計画信息
    public void deleteByKeys(String stuId, String subjectId, String fixedWeek) {
        knFixLsn001Mapper.deleteInfoByKeys(stuId, subjectId, fixedWeek);
    }

    // 新增固定授業計画信息
    private void insert(KnFixLsn001Bean knFixLsn001Bean) {
        // System.out.println("插入的固定授業計画管理数据：" + knFixLsn001Bean.toString());
        knFixLsn001Mapper.insertInfo(knFixLsn001Bean);
    }

    // 更新固定授業計画信息
    private void update(KnFixLsn001Bean knFixLsn001Bean) {
        // System.out.println("更新的固定授業計画管理数据：" + knFixLsn001Bean.toString());
        knFixLsn001Mapper.updateInfo(knFixLsn001Bean);
    }
}
