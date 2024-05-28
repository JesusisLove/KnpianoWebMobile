package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn01L001SubBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn01L001SubMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class Kn01L001SubDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn01L001SubMapper knSub001Mapper;

    // 画面初期化显示所科目信息
    public List<Kn01L001SubBean> getInfoList() {
        List<Kn01L001SubBean> list = knSub001Mapper.getInfoList();
        // System.out.println("select的KN_SUB_001数据：" + list.toString());
        return list;
    }

    // 获取所有符合查询条件的科目信息
    public List<Kn01L001SubBean> searchSubjects(Map<String, Object> params) {
        return knSub001Mapper.searchSubjects(params);
    }

    // 根据ID获取科目信息
    public Kn01L001SubBean getInfoById(String id) {
        Kn01L001SubBean knSub001Bean = knSub001Mapper.getInfoById(id);
        // System.out.println("select的KN_SUB_001数据：" + knSub001Bean.toString());
        return knSub001Bean;
    }

    // 保存科目信息（新建或更新）
    public void save(Kn01L001SubBean knSub001Bean) {
        if (knSub001Bean.getSubjectId() == null || knSub001Bean.getSubjectId().isEmpty()) { 
            Map<String, Object> map = new HashMap<>();
            map.put("parm_in", KNConstant.CONSTANT_KN_SUB_SEQ);
            // 科目ID的自动编号
            knSub001Mapper.getNextSequence(map);
            knSub001Bean.setSubjectId(KNConstant.CONSTANT_KN_SUB_SEQ + (Integer)map.get("parm_out"));
            System.out.println(map.get("parm_out"));
            insert(knSub001Bean);
        } else {
            update(knSub001Bean);
        }
    } 

    // 新增科目信息
    private void insert(Kn01L001SubBean knSub001Bean) {
        // System.out.println("insert的KN_SUB_001数据：" + knSub001Bean.toString());
        knSub001Mapper.insertInfo(knSub001Bean);
    }

    // 更新科目信息
    private void update(Kn01L001SubBean knSub001Bean) {
        // System.out.println("update的KN_SUB_001数据：" + knSub001Bean.toString());
        knSub001Mapper.updateInfo(knSub001Bean);
    }

    // 删除科目信息
    public void delete(String id) { 
        System.out.println("delete的KN_SUB_001数据：科目ID = " + id);
        knSub001Mapper.deleteInfo(id); 
    }
}
