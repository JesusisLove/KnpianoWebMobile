package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.constant.KNSeqConstant;
import com.liu.springboot04web.mapper.KnStu001Mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class KnStu001Dao implements BzlFudousanDao {

    @Autowired
    private KnStu001Mapper knStu001Mapper;

    // 画面初期化显示所有学生信息
    public List<KnStu001Bean> getInfoList() {
        List<KnStu001Bean> list =knStu001Mapper.getInfoList();
        // System.out.println("selectのKN_STU_001データ：" + list.toString());
        return list;
    }

    // 获取所有符合查询条件的学生信息
    public List<KnStu001Bean> searchStudents(Map<String, Object> params) {
        return knStu001Mapper.searchStudents(params);
    }

    public KnStu001Bean getInfoById(String id) {
    KnStu001Bean knStu001Bean = knStu001Mapper.getInfoById(id);
    // System.out.println("selectのKN_STU_001データ：" + knStu001Bean.toString());
    return knStu001Bean;
    }

    public void save(KnStu001Bean knStu001Bean) {
        if (knStu001Bean.getStuId() == null 
        || knStu001Bean.getStuId().isEmpty()) { 

            Map<String, Object> map = new HashMap<String, Object> ();
            map.put("parm_in", KNSeqConstant.CONSTANT_KN_STU_SEQ);
            // 学生の名前の自動採番
            knStu001Mapper.getNextSequence(map);
            knStu001Bean.setStuId(KNSeqConstant.CONSTANT_KN_STU_SEQ+(Integer)map.get("parm_out"));
            System.out.println(map.get("parm_out"));
            insert(knStu001Bean);
        } else {
            update(knStu001Bean);
        }
    } 

    // 新規
    private void insert(KnStu001Bean knStu001Bean) {
        // System.out.println("insertのKN_STU_001データ：" + knStu001Bean.toString());
        knStu001Mapper.insertInfo(knStu001Bean);

    }


    // 変更
    private void update(KnStu001Bean knStu001Bean) {
        // System.out.println("updateのKN_STU_001データ：" + knStu001Bean.toString());
        knStu001Mapper.updateInfo(knStu001Bean);
    }


    // 削除
    public void delete(String id) { 
        System.out.println("deleteのKN_STU_001データ：学生番号 = " + id);
        knStu001Mapper.deleteInfo(id); 
    }
}
