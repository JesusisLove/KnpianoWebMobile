package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn03D003StubnkBean;
import com.liu.springboot04web.mapper.Kn03D003StubnkMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public class Kn03D003StubnkDao {

    @Autowired
    private Kn03D003StubnkMapper kn05S002StubnkMapper;

    public List<Kn03D003StubnkBean> getInfoList() {
        List<Kn03D003StubnkBean> list = kn05S002StubnkMapper.getInfoList();
        return list;
    }

    public List<Kn03D003StubnkBean> getInfoById(String stuId) {
        List<Kn03D003StubnkBean> list = kn05S002StubnkMapper.getInfoById(stuId);
        return list;
    }

    public Kn03D003StubnkBean getInfoById(String stuId, String bankId) {
        Kn03D003StubnkBean kn05S002StubnkBean = kn05S002StubnkMapper.getInfoByStuIdBnkId(stuId, bankId);
        return kn05S002StubnkBean;
    }

    // 手机前端该当银行被学生使用的学生信息抽出
    public List<Kn03D003StubnkBean> getInfoByBnkId(String bankId) {
        List<Kn03D003StubnkBean> list = kn05S002StubnkMapper.getInfoByBnkId(bankId);
        return list;
    }

    public void save(Kn03D003StubnkBean kn05S002StubnkBean) {
        if (getInfoById(kn05S002StubnkBean.getStuId(), kn05S002StubnkBean.getBankId()) == null) { 

            insert(kn05S002StubnkBean);
        } else {
            update(kn05S002StubnkBean);
        }
    }

    // 新規
    private void insert(Kn03D003StubnkBean kn05S002StubnkBean) {
        kn05S002StubnkMapper.insertInfo(kn05S002StubnkBean);

    }

    // 変更
    private void update(Kn03D003StubnkBean kn05S002StubnkBean) {
        kn05S002StubnkMapper.updateInfo(kn05S002StubnkBean);
    }

    // 削除
    public void delete(String stuId, String bankId) { 
        kn05S002StubnkMapper.deleteInfo(stuId, bankId); 
    }
}
