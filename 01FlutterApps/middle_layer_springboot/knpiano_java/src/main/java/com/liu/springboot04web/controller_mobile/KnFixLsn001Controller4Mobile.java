package com.liu.springboot04web.controller_mobile;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.liu.springboot04web.bean.KnFixLsn001Bean;
import com.liu.springboot04web.dao.KnFixLsn001Dao;
import java.util.Collection;

@RestController
public class KnFixLsn001Controller4Mobile {

    @Autowired
    KnFixLsn001Dao knFixLsn001Dao;

    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_fixlsn_001_all")
    public ResponseEntity<Collection<KnFixLsn001Bean>> getStudentList() {
        // 获取当前正在上课的所有学生信息
        Collection<KnFixLsn001Bean> collection = knFixLsn001Dao.getInfoList();
        return ResponseEntity.ok(collection);
    }


    // Chrome浏览器模式下，origins 属性指定了允许发起跨域请求的来源
    //@CrossOrigin(origins = "https://example.com") // 生产环境下使用，一定要指定某个具体的url
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/......")
    public ResponseEntity<KnFixLsn001Bean> getStudentByName(@RequestParam String stuid) {
        // 学生番号より、学生情報を検索する。
        KnFixLsn001Bean knStu001Bean = knFixLsn001Dao.getInfoById(stuid);
        return ResponseEntity.ok(knStu001Bean);
    }


    // 【新規登録】画面にて、【保存】ボタンを押下
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_fixlsn_001_add")
    public String excuteInfoAdd(@RequestBody KnFixLsn001Bean knStu001Bean) {
        knFixLsn001Dao.save(knStu001Bean);
        return "Success";
    }
}

