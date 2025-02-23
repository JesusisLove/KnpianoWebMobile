package com.liu.springboot04web.controller_mobile;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collection;

import com.liu.springboot04web.bean.Kn03D002SubBean;
import com.liu.springboot04web.dao.Kn03D002SubDao;

@RestController
public class Kn03D002SubController4Mobile {

    @Autowired
    Kn03D002SubDao knSub001Dao;

    // @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_sub_001_all")
    public ResponseEntity<Collection<Kn03D002SubBean>> getSubdentList() {
        // 获取目前所有科目信息显示在画面一览上
        Collection<Kn03D002SubBean> collection = knSub001Dao.getInfoList();
        return ResponseEntity.ok(collection);
    }

    // 【新規/编辑】画面にて、【保存】ボタンを押下
    // @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_sub_001")
    public void excuteInfoAdd(@RequestBody Kn03D002SubBean knSub001Bean) {
        knSub001Dao.save(knSub001Bean);
    }

    // 【学科一覧】削除ボタンを押下
    // @CrossOrigin(origins = "*") 
    @DeleteMapping("/mb_kn_sub_001/{id}")
    public ResponseEntity<String> executeInfoDelete(@PathVariable("id") String id) {
        try {
            knSub001Dao.delete(id);
            return ResponseEntity.ok("success");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)  // 409 Conflict
                    .body("学科编号为【" + id + "】的科目在使用。所以删除不了。");
        }
    }
    
}

