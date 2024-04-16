package com.liu.springboot04web.controller;

import org.springframework.web.bind.annotation.CrossOrigin;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.dao.KnStu001Dao;

@RestController
public class KnStu001MobileController {

    @Autowired
    KnStu001Dao knStu001Dao;

    // Chrome浏览器模式下，origins 属性指定了允许发起跨域请求的来源
    //@CrossOrigin(origins = "https://example.com") // 生产环境下使用，一定要指定某个具体的url
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/student")

 
    public ResponseEntity<KnStu001Bean> getStudentByName(@RequestParam String stuid) {
        // 学生番号より、学生情報を検索する。
        KnStu001Bean knStu001Bean = knStu001Dao.getInfoById(stuid);
        return ResponseEntity.ok(knStu001Bean);
    }
}

