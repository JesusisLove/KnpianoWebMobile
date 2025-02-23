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

import com.liu.springboot04web.bean.Kn03D003BnkBean;
import com.liu.springboot04web.dao.Kn03D003BnkDao;

@RestController
public class Kn03D003BnkController4Mobile {

    @Autowired
    Kn03D003BnkDao knBnk001Dao;

    // @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_03d003_bank_all")
    public ResponseEntity<Collection<Kn03D003BnkBean>> getBankList() {
        // 获取目前所有科目信息显示在画面一览上
        Collection<Kn03D003BnkBean> collection = knBnk001Dao.getInfoList();
        return ResponseEntity.ok(collection);
    }

    // 【新規/编辑】画面にて、【保存】ボタンを押下
    // @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_03d003_bank")
    public void excuteInfoAdd(@RequestBody Kn03D003BnkBean knSub001Bean) {
        knBnk001Dao.save(knSub001Bean);
    }

    // 【银行一覧】削除ボタンを押下
    // @CrossOrigin(origins = "*") 
    @DeleteMapping("/mb_kn_03d003_bank/{id}")
    public ResponseEntity<String> executeInfoDelete(@PathVariable("id") String id) {
        try {
            knBnk001Dao.delete(id);
            return ResponseEntity.ok("success");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)  // 409 Conflict
                    .body("银行编号为【" + id + "】的银行名称在使用。所以删除不了。");
        }
    }
    
}