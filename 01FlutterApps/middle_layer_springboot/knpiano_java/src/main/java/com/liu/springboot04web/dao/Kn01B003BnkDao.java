package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn01B003BnkBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn01B003BnkMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class Kn01B003BnkDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn01B003BnkMapper knBnk001Mapper;

    // 获取所有银行信息
    public List<Kn01B003BnkBean> getInfoList() {
        return knBnk001Mapper.getInfoList();
    }

    /* 画面检索 检索功能追加  开始 */ 
    // 获取所有符合查询条件的银行信息
    public List<Kn01B003BnkBean> searchBanks(Map<String, Object> params) {
        return knBnk001Mapper.searchBanks(params);
    }
    /* 画面检索 检索功能追加  结束 */ 

    // 根据ID获取银行信息
    public Kn01B003BnkBean getInfoById(String id) {
         Kn01B003BnkBean knBnk001Bean = knBnk001Mapper.getInfoById(id);
         return knBnk001Bean;
    }

    // 保存银行信息（新建或更新）
    public void save(Kn01B003BnkBean knBnk001Bean) {
        if (knBnk001Bean.getBankId() == null || knBnk001Bean.getBankId().isEmpty()) { 
            Map<String, Object> map = new HashMap<>();
            map.put("parm_in", KNConstant.CONSTANT_KN_BNK_SEQ);

            knBnk001Mapper.getNextSequence(map);
            knBnk001Bean.setBankId(KNConstant.CONSTANT_KN_BNK_SEQ + (Integer)map.get("parm_out"));
            insert(knBnk001Bean);
        } else {
            update(knBnk001Bean);
        }
    } 

    // 新增银行信息
    private void insert(Kn01B003BnkBean knBnk001Bean) {
        knBnk001Mapper.insertInfo(knBnk001Bean);
    }

    // 更新银行信息
    private void update(Kn01B003BnkBean knBnk001Bean) {
        knBnk001Mapper.updateInfo(knBnk001Bean);
    }

    // 删除银行信息
    public void delete(String id) { 
        knBnk001Mapper.deleteInfo(id); 
    }
}
