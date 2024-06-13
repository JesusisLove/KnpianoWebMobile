package com.liu.springboot04web.dao;

import com.liu.springboot04web.bean.Kn05S002StubnkBean;
import com.liu.springboot04web.mapper.Kn05S002StubnkMapper;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public class Kn05S002StubnkDao {

    @Autowired
    private Kn05S002StubnkMapper kn05S002StubnkMapper;

    public List<Kn05S002StubnkBean> getInfoList() {
        List<Kn05S002StubnkBean> list = kn05S002StubnkMapper.getInfoList();
        return list;
    }

    public List<Kn05S002StubnkBean> getInfoById(String stuId) {
        List<Kn05S002StubnkBean> list = kn05S002StubnkMapper.getInfoByStuId(stuId);
        return list;
    }

    public Kn05S002StubnkBean getInfoById(String stuId, String bankId) {
        Kn05S002StubnkBean kn05S002StubnkBean = kn05S002StubnkMapper.getInfoByStuIdBnkId(stuId, bankId);
        return kn05S002StubnkBean;
    }

    public void save(Kn05S002StubnkBean kn05S002StubnkBean) {
        if (getInfoById(kn05S002StubnkBean.getStuId(), kn05S002StubnkBean.getBankId()) == null) { 

            insert(kn05S002StubnkBean);
        } else {
            update(kn05S002StubnkBean);
        }
    }

    // 新規
    private void insert(Kn05S002StubnkBean kn05S002StubnkBean) {
        kn05S002StubnkMapper.insertInfo(kn05S002StubnkBean);

    }

    // 変更
    private void update(Kn05S002StubnkBean kn05S002StubnkBean) {
        kn05S002StubnkMapper.updateInfo(kn05S002StubnkBean);
    }

    // 削除
    public void delete(String id) { 
        kn05S002StubnkMapper.deleteInfo(id); 
    }
}
