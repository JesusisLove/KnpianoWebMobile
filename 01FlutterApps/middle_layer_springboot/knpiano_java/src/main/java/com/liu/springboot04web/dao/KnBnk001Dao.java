package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.KnBnk001Bean;
import com.liu.springboot04web.constant.KNSeqConstant;
import com.liu.springboot04web.mapper.KnBnk001Mapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class KnBnk001Dao implements InterfaceKnPianoDao {

    @Autowired
    private KnBnk001Mapper knBnk001Mapper;

    // 获取所有银行信息
    public List<KnBnk001Bean> getInfoList() {
        return knBnk001Mapper.getInfoList();
    }

    /* 画面检索 检索功能追加  开始 */ 
    // 获取所有符合查询条件的银行信息
    public List<KnBnk001Bean> searchBanks(Map<String, Object> params) {
        return knBnk001Mapper.searchBanks(params);
    }
    /* 画面检索 检索功能追加  结束 */ 

    // 根据ID获取银行信息
    public KnBnk001Bean getInfoById(String id) {
         KnBnk001Bean knBnk001Bean = knBnk001Mapper.getInfoById(id);
         return knBnk001Bean;
    }

    // 保存银行信息（新建或更新）
    public void save(KnBnk001Bean knBnk001Bean) {
        if (knBnk001Bean.getBankId() == null || knBnk001Bean.getBankId().isEmpty()) { 
            Map<String, Object> map = new HashMap<>();
            map.put("parm_in", KNSeqConstant.CONSTANT_KN_BNK_SEQ);

            knBnk001Mapper.getNextSequence(map);
            knBnk001Bean.setBankId(KNSeqConstant.CONSTANT_KN_BNK_SEQ + (Integer)map.get("parm_out"));
            insert(knBnk001Bean);
        } else {
            update(knBnk001Bean);
        }
    } 

    // 新增银行信息
    private void insert(KnBnk001Bean knBnk001Bean) {
        knBnk001Mapper.insertInfo(knBnk001Bean);
    }

    // 更新银行信息
    private void update(KnBnk001Bean knBnk001Bean) {
        knBnk001Mapper.updateInfo(knBnk001Bean);
    }

    // 删除银行信息
    public void delete(String id) { 
        knBnk001Mapper.deleteInfo(id); 
    }
}
