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

import com.liu.springboot04web.bean.Kn03D002SubEdaBanBean;
import com.liu.springboot04web.dao.Kn03D002SubEdaBanDao;

@RestController
public class Kn03D002SubEdaBanController4Mobile {

    @Autowired
    Kn03D002SubEdaBanDao kn05S003SubjectEdabnDao;

    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_05s003_subject_edabn_by_subid/{subId}")
    public ResponseEntity<Collection<Kn03D002SubEdaBanBean>> getSubdentList(@PathVariable("subId") String subId) {
        // 获取目前所有科目信息显示在画面一览上
        Collection<Kn03D002SubEdaBanBean> collection = kn05S003SubjectEdabnDao.getSubEdaList(subId);
        return ResponseEntity.ok(collection);
    }

    // 【新規/编辑】画面にて、【保存】ボタンを押下
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_05s003_subject_edabn")
    public void excuteInfoAdd(@RequestBody Kn03D002SubEdaBanBean knSub001Bean) {
        kn05S003SubjectEdabnDao.save(knSub001Bean);
    }

    // 【学科一覧】削除ボタンを押下
    @CrossOrigin(origins = "*") 
    @DeleteMapping("/mb_kn_05s003_subject_edabn/{subId}/{edabanId}")
    public ResponseEntity<String> executeInfoDelete(@PathVariable("subId") String subId,
                                                    @PathVariable("edabanId") String edabanId) {
        try {
            kn05S003SubjectEdabnDao.delete(subId, edabanId);
            return ResponseEntity.ok("success");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)  // 409 Conflict
                    .body("学科级别编号为【" + edabanId + "】的科目有学生在用。所以删除不了。");
        }
    }
}
