package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn05S001LsnFixBean;
import com.liu.springboot04web.mapper.Kn05S001LsnFixMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class Kn05S001LsnFixDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn05S001LsnFixMapper knFixLsn001Mapper;
    
    // 获取所有固定授業計画的信息列表
    public List<Kn05S001LsnFixBean> getInfoList() {
        List<Kn05S001LsnFixBean> list = knFixLsn001Mapper.getInfoList();
        return list;
    }

    // 获取所有符合查询条件的学生固定排课信息
    public List<Kn05S001LsnFixBean> searchFixedLessons(Map<String, Object> params) {
        return knFixLsn001Mapper.searchFixedLessons(params);
    }

    // 根据ID获取信息(该方法不使用，为什么不删除？因为implements InterfaceKnPianoDao)
    public Kn05S001LsnFixBean getInfoById(String id) {
        return null;
   }

    // 根据ID获取特定的固定授業計画信息
    public Kn05S001LsnFixBean getInfoByKey(String stuId, String subjectId, String fixedWeek) {
        Kn05S001LsnFixBean knFixLsn001Bean = knFixLsn001Mapper.getInfoById(stuId, subjectId, fixedWeek);
        return knFixLsn001Bean;
    }

    // 保存或更新固定授業計画信息
    public void save(Kn05S001LsnFixBean knFixLsn001Bean, boolean addNewMode) {

        // 确认表里有没有记录，没有就insert，有记录就update
        if (addNewMode) {
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
    private void insert(Kn05S001LsnFixBean knFixLsn001Bean) {
        knFixLsn001Mapper.insertInfo(knFixLsn001Bean);
    }

    // 更新固定授業計画信息
    private void update(Kn05S001LsnFixBean knFixLsn001Bean) {
        knFixLsn001Mapper.updateInfo(knFixLsn001Bean);
    }
}
