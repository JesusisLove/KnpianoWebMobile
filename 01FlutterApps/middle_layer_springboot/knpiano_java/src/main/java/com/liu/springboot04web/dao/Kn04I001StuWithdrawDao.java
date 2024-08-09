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
    // 后台维护：画面初期化显示所有学生信息
    public List<Kn03D001StuBean> getInfoList() {
        List<Kn03D001StuBean> list = knStu001Mapper.getInfoList();
        return list;
    }

    // 手机前端：画面初期化显示所有学生信息
    public List<Kn03D001StuBean> getInfoList(String stuId, Integer delFlg) {
        List<Kn03D001StuBean> list = knStu001Mapper.getInfoListWitParm(stuId, delFlg);
        return list;
    }

    // 后端维护的Web页面里的休学/退学处理
    public void stuWithdraw(String stuId) {
        knStu001Mapper.stuWithdrawProcessSingle(stuId);
    }

    // 手机前端页面里的休学/退学处理（可选复述个学生）
    public void stuWithdraw(List<Kn03D001StuBean> beans) {
        knStu001Mapper.stuWithdrawProcessList(beans);
    }

    // 前端手机，后端维护的web页面都调用此复学处理
    public void stuReinstatement(String stuId) {
        knStu001Mapper.stuReinstatement(stuId);
    }
}
