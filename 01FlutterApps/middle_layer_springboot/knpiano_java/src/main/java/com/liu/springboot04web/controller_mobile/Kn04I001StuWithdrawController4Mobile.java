package com.liu.springboot04web.controller_mobile;

import java.util.Collection;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn03D001StuBean;
import com.liu.springboot04web.dao.Kn04I001StuWithdrawDao;

@RestController
@Service
public class Kn04I001StuWithdrawController4Mobile {

    @Autowired
    Kn04I001StuWithdrawDao knStu001Dao;

    // 手机前端退学休学的学生信息取得
    @CrossOrigin(origins = "*")
    @GetMapping("/mb_kn_stu_leave_all")
    public ResponseEntity<Collection<Kn03D001StuBean>> getStuLeaveList() {
        // 获取休学学生信息
        Collection<Kn03D001StuBean> collection = knStu001Dao.getInfoList(null, 1);
        return ResponseEntity.ok(collection);
    }

    // 手机前端退学休学的学生信息取得
    @CrossOrigin(origins = "*") //
    @GetMapping("/mb_kn_stu_onLsn_all")
    public ResponseEntity<Collection<Kn03D001StuBean>> getStuOnLesonList() {
        // 获取休学学生信息
        Collection<Kn03D001StuBean> collection = knStu001Dao.getInfoList(null, 0);
        return ResponseEntity.ok(collection);
    }

    // 手机前端执行学生退学/休学处理，可选复述个学生一并执行
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @PostMapping("/mb_kn_stu_leave")
    public ResponseEntity<String> stuWithdraw(@RequestBody List<Kn03D001StuBean> beans) {
        // 处理多个对象的逻辑
        knStu001Dao.stuWithdraw(beans);
        return ResponseEntity.ok("退学处理成功");
    }

    // 手机前端执行学生复学处理，只能是单个执行
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @PostMapping("/mb_kn_stu_return/{stuId}")
    public ResponseEntity<String> excuteReturn( @PathVariable("stuId") String stuId) {
        // 处理多个对象的逻辑
        knStu001Dao.stuReinstatement(stuId);
        return ResponseEntity.ok("复学处理成功");
    }

}
