package com.liu.springboot04web.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.liu.springboot04web.bean.Kn03D001StuBean;
import com.liu.springboot04web.mapper.Kn04I001StuWithdrawMapper;

import java.util.List;

@Repository
public class Kn04I001StuWithdrawDao {

    @Autowired
    private Kn04I001StuWithdrawMapper knStu001Mapper;

    // 画面初期化显示所有学生信息
    public List<Kn03D001StuBean> getInfoList() {
        List<Kn03D001StuBean> list = knStu001Mapper.getInfoList();
        return list;
    }

    // 休学/退学处理
    public void stuWithdraw(String stuId) {
        knStu001Mapper.stuWithdrawProcessSingle(stuId);
    }

    // 复学处理
    public void stuReinstatement(String stuId) {
        knStu001Mapper.stuReinstatement(stuId);
    }
}
