package com.liu.springboot04web.dao;


import com.liu.springboot04web.constant.KNSeqConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.KnLsnFee001Bean;
import com.liu.springboot04web.bean.KnPianoBean;
import com.liu.springboot04web.mapper.KnLsnFee001Mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class KnLsnFee001Dao implements InterfaceKnPianoDao {

    @Autowired
    private KnLsnFee001Mapper knLsnFee001Mapper;

    // 画面初期化显示所科目信息
    public List<KnLsnFee001Bean> getInfoList() {
        List<KnLsnFee001Bean> list =knLsnFee001Mapper.getInfoList();
        return list;
    }

    // 获取所有符合查询条件的课费信息
    public List<KnLsnFee001Bean> searchLsnFee(Map<String, Object> params) {
        return knLsnFee001Mapper.searchLsnFee(params);
    }

    // 根据ID获取课费信息
    public KnLsnFee001Bean getInfoById(String lsnFeeId, String lessonId) {
        KnLsnFee001Bean knLsnFee001Bean = knLsnFee001Mapper.getInfoById(lsnFeeId, lessonId);
        return knLsnFee001Bean;
    }

    public void save(KnLsnFee001Bean knLsnFee001Bean) {
        if (knLsnFee001Bean.getLsnFeeId() == null || knLsnFee001Bean.getLsnFeeId().isEmpty()) { 
            Map<String, Object> map = new HashMap<>();
            map.put("parm_in", KNSeqConstant.CONSTANT_KN_LSN_FEE_SEQ);
            // 授業番号の自動採番
            knLsnFee001Mapper.getNextSequence(map);
            knLsnFee001Bean.setLsnFeeId(KNSeqConstant.CONSTANT_KN_LSN_FEE_SEQ + (Integer)map.get("parm_out"));
            System.out.println(map.get("parm_out"));
            insert(knLsnFee001Bean);
        } else {
            update(knLsnFee001Bean);
        }
    }

    // 新規
    private void insert(KnLsnFee001Bean knLsnFee001Bean) {
        knLsnFee001Mapper.insertInfo(knLsnFee001Bean);
    }

    // 変更
    private void update(KnLsnFee001Bean knLsnFee001Bean) {
        knLsnFee001Mapper.updateInfo(knLsnFee001Bean);
    }

    // 削除
    public void delete(String lsnFeeId, String lessonId) {
        knLsnFee001Mapper.deleteInfo(lsnFeeId, lessonId); 
    }

    @Override
    public KnPianoBean getInfoById(String id) {
        throw new UnsupportedOperationException("Unimplemented method 'getInfoById'");
    }
}







































