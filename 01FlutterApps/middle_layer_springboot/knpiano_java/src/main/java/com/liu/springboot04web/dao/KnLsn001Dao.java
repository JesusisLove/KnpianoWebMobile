package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnLsn001Bean;
import com.liu.springboot04web.constant.KNSeqConstant;
import com.liu.springboot04web.mapper.KnLsn001Mapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;@Repository
public class KnLsn001Dao implements InterfaceKnPianoDao {

@Autowired
private KnLsn001Mapper knLsn001Mapper;

public List<KnLsn001Bean> getInfoList() {
List<KnLsn001Bean> list =knLsn001Mapper.getInfoList();
// System.out.println("selectの学生授業情報管理データ：" + list.toString());
return list;
}

// 获取所有符合查询条件的课程信息
public List<KnLsn001Bean> searchLessons(Map<String, Object> params) {
    return knLsn001Mapper.searchLessons(params);
}

public KnLsn001Bean getInfoById(String id) {
KnLsn001Bean knLsn001Bean = knLsn001Mapper.getInfoById(id);
// System.out.println("selectの学生授業情報管理データ：" + knLsn001Bean.toString());
return knLsn001Bean;
}

public void save(KnLsn001Bean knLsn001Bean) {
    if (knLsn001Bean.getLessonId() == null 
    || knLsn001Bean.getLessonId().isEmpty()) { 

        Map<String, Object> map = new HashMap<String, Object> ();
            map.put("parm_in", KNSeqConstant.CONSTANT_KN_LSN_SEQ);
            // 授業自動採番
            knLsn001Mapper.getNextSequence(map);
            knLsn001Bean.setLessonId(KNSeqConstant.CONSTANT_KN_LSN_SEQ+(Integer)map.get("parm_out"));

        // 授業番号の自動採番
        knLsn001Mapper.getNextSequence(map);
        // System.out.println(map.get("parm_out"));
        insert(knLsn001Bean);
    } else {
        update(knLsn001Bean);
    }
}

// 新規
private void insert(KnLsn001Bean knLsn001Bean) {
// System.out.println("insertの学生授業情報管理データ：" + knLsn001Bean.toString());
knLsn001Mapper.insertInfo(knLsn001Bean);
}

// 変更
private void update(KnLsn001Bean knLsn001Bean) {
// System.out.println("updateの学生授業情報管理データ：" + knLsn001Bean.toString());
knLsn001Mapper.updateInfo(knLsn001Bean);
}

// 削除
public void delete(String id) { 
// System.out.println("deleteの学生授業情報管理データ：keiyaku_mng_no = " + id);
knLsn001Mapper.deleteInfo(id); 
}
}