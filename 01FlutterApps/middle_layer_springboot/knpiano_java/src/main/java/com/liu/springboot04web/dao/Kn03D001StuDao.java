package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn03D001StuBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn03D001StuMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class Kn03D001StuDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn03D001StuMapper knStu001Mapper;

    // 画面初期化显示所有学生信息
    public List<Kn03D001StuBean> getInfoList() {
        List<Kn03D001StuBean> list =knStu001Mapper.getInfoList();
        return list;
    }

    // 获取所有符合查询条件的学生信息
    public List<Kn03D001StuBean> searchStudents(Map<String, Object> params) {
        return knStu001Mapper.searchStudents(params);
    }

    public Kn03D001StuBean getInfoById(String id) {
    Kn03D001StuBean knStu001Bean = knStu001Mapper.getInfoById(id);
    return knStu001Bean;
    }

    public void save(Kn03D001StuBean knStu001Bean) {
        if (knStu001Bean.getStuId() == null 
        || knStu001Bean.getStuId().isEmpty()) { 

            Map<String, Object> map = new HashMap<String, Object> ();
            map.put("parm_in", KNConstant.CONSTANT_KN_STU_SEQ);
            // 学生の名前の自動採番
            knStu001Mapper.getNextSequence(map);
            knStu001Bean.setStuId(KNConstant.CONSTANT_KN_STU_SEQ+(Integer)map.get("parm_out"));
            insert(knStu001Bean);
        } else {
            update(knStu001Bean);
        }
    } 

    // 新規
    private void insert(Kn03D001StuBean knStu001Bean) {
        knStu001Mapper.insertInfo(knStu001Bean);
    }

    // 変更
    private void update(Kn03D001StuBean knStu001Bean) {
        knStu001Mapper.updateInfo(knStu001Bean);
    }

    // 休学/退学处理
    public void stuWithdraw(String stuId) {
        knStu001Mapper.stuWithdraw(stuId);
    }

    // 复学处理
    public void stuReinstatement(String stuId) {
        knStu001Mapper.stuReinstatement(stuId);
    }

    // 削除
    public void delete(String id) { 
        knStu001Mapper.deleteInfo(id); 
    }
}
