package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn05S002StubnkBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.mapper.Kn05S002StubnkMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;@Repository
public class Kn05S002StubnkDao implements InterfaceKnPianoDao {

    @Autowired
    private Kn05S002StubnkMapper kn05S002StubnkMapper;

    public List<Kn05S002StubnkBean> getInfoList() {
        List<Kn05S002StubnkBean> list =kn05S002StubnkMapper.getInfoList();
        System.out.println("selectの学生銀行番号管理データ：" + list.toString());
        return list;
    }


    public Kn05S002StubnkBean getInfoById(String id) {
        Kn05S002StubnkBean kn05S002StubnkBean = kn05S002StubnkMapper.getInfoById(id);
        System.out.println("selectの学生銀行番号管理データ：" + kn05S002StubnkBean.toString());
        return kn05S002StubnkBean;
    }

    public void save(Kn05S002StubnkBean kn05S002StubnkBean) {
        if ((kn05S002StubnkBean.getBankId() == null) || (kn05S002StubnkBean.getBankId().isEmpty()) && 
            (kn05S002StubnkBean.getStuId() == null)|| (kn05S002StubnkBean.getStuId().isEmpty())) { 

            insert(kn05S002StubnkBean);
        } else {
            update(kn05S002StubnkBean);
        }
    }


    // 新規
    private void insert(Kn05S002StubnkBean kn05S002StubnkBean) {
        System.out.println("insertの学生銀行番号管理データ：" + kn05S002StubnkBean.toString());
        kn05S002StubnkMapper.insertInfo(kn05S002StubnkBean);

    }


    // 変更
    private void update(Kn05S002StubnkBean kn05S002StubnkBean) {
        System.out.println("updateの学生銀行番号管理データ：" + kn05S002StubnkBean.toString());
        kn05S002StubnkMapper.updateInfo(kn05S002StubnkBean);
    }


    // 削除
    public void delete(String id) { 
        System.out.println("deleteの学生銀行番号管理データ：keiyaku_mng_no = " + id);
        kn05S002StubnkMapper.deleteInfo(id); 
    }
}
