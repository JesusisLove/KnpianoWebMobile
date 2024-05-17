package com.liu.springboot04web.controller_mobile;

import org.springframework.web.bind.annotation.CrossOrigin;

import java.util.Collection;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.liu.springboot04web.bean.Kn03D001StuBean;
import com.liu.springboot04web.dao.Kn03D001StuDao;

@RestController
public class Kn03D001StuController4Mobile {

    @Autowired
    Kn03D001StuDao knStu001Dao;

    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_stu_001_all")
    public ResponseEntity<Collection<Kn03D001StuBean>> getStudentList() {
        // 获取当前正在上课的所有学生信息
        Collection<Kn03D001StuBean> collection = knStu001Dao.getInfoList();
        return ResponseEntity.ok(collection);
    }


    // Chrome浏览器模式下，origins 属性指定了允许发起跨域请求的来源
    //@CrossOrigin(origins = "https://example.com") // 生产环境下使用，一定要指定某个具体的url
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/student")
    public ResponseEntity<Kn03D001StuBean> getStudentByName(@RequestParam String stuid) {
        // 学生番号より、学生情報を検索する。
        Kn03D001StuBean knStu001Bean = knStu001Dao.getInfoById(stuid);
        return ResponseEntity.ok(knStu001Bean);
    }


    // 【新規登録】画面にて、【保存】ボタンを押下
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_stu_001_add")
    public void excuteInfoAdd(@RequestBody Kn03D001StuBean knStu001Bean) {
        knStu001Dao.save(knStu001Bean);
    }


    // 【学生档案编辑】画面にて、【保存】ボタンを押下
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_stu_001_edit")
    public void excuteInfoEdit(@RequestBody Kn03D001StuBean knStu001Bean) {
        knStu001Dao.save(knStu001Bean);
    }
}

