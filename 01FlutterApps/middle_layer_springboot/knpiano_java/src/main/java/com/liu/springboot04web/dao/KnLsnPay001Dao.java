package com.liu.springboot04web.dao;

import com.liu.springboot04web.constant.KNSeqConstant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.KnLsnPay001Bean;
import com.liu.springboot04web.mapper.KnLsnPay001Mapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class KnLsnPay001Dao implements InterfaceKnPianoDao {

    @Autowired
    private KnLsnPay001Mapper knLsnPay001Mapper;

    // 画面初期化显示所科目信息
    public List<KnLsnPay001Bean> getInfoList() {
        List<KnLsnPay001Bean> list =knLsnPay001Mapper.getInfoList();
        return list;
    }

    // 获取所有符合查询条件的支付信息
    public List<KnLsnPay001Bean> searchLsnPay(Map<String, Object> params) {
        return knLsnPay001Mapper.searchLsnPay(params);
    }

    // 根据ID获取课费支付信息
    public KnLsnPay001Bean getInfoById(String id) {
        return null;
    }

    public KnLsnPay001Bean getInfoById(String lsnPayId, String lsnFeeId) {
        KnLsnPay001Bean knLsnPay001Bean = knLsnPay001Mapper.getInfoById(lsnPayId, lsnFeeId);
        return knLsnPay001Bean;
    }

    // 保存课费支付信息（新建或更新）
    public void save(KnLsnPay001Bean knLsnPay001Bean) {
        if (knLsnPay001Bean.getLsnPayId() == null || knLsnPay001Bean.getLsnPayId().isEmpty()) { 
        
            Map<String, Object> map = new HashMap<>();
            map.put("parm_in", KNSeqConstant.CONSTANT_KN_LSN_PAY_SEQ);
            // 授業課費番号の自動採番
            knLsnPay001Mapper.getNextSequence(map);
            knLsnPay001Bean.setLsnPayId(KNSeqConstant.CONSTANT_KN_LSN_PAY_SEQ + (Integer)map.get("parm_out"));

            insert(knLsnPay001Bean);
        } else {
            update(knLsnPay001Bean);
        }
    }

    // 新規支付课费
    private void insert(KnLsnPay001Bean knLsnPay001Bean) {
        knLsnPay001Mapper.insertInfo(knLsnPay001Bean);
    }

    // 修改支付课费
    private void update(KnLsnPay001Bean knLsnPay001Bean) {
        knLsnPay001Mapper.updateInfo(knLsnPay001Bean);
    }

    // 削除支付课费
    public void delete(String lsnPayId, String lsnFeeId) { 
        knLsnPay001Mapper.deleteInfo(lsnPayId, lsnFeeId); 
    }
}
