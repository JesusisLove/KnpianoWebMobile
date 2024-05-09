package com.liu.springboot04web.controller_mobile;

import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import com.liu.springboot04web.bean.KnFixLsn001Bean;
import com.liu.springboot04web.dao.KnFixLsn001Dao;
import java.util.Collection;
import java.util.List;

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

    // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_fixlsn_stusub_get")
    private ResponseEntity<Collection<KnFixLsn001Bean>> getStuSubList() {
        List<KnFixLsn001Bean> list = knFixLsn001Dao.getLatestSubjectList();
        return ResponseEntity.ok(list);
    }

    // 【新規登録/変更編集】画面にて、【保存】ボタンを押下
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_fixlsn_001")
    public void excuteInfoAdd(@RequestBody KnFixLsn001Bean knStu001Bean) {
        knFixLsn001Dao.save(knStu001Bean);
    }

    // 【排课一覧】削除ボタンを押下
    @CrossOrigin(origins = "*") 
    @DeleteMapping("/mb_kn_fixlsn_001/{stuId}/{subjectId}/{fixedWeek}")
    public ResponseEntity<String> executeFixedLessonDelete(@PathVariable("stuId") String stuId, 
                                                           @PathVariable("subjectId") String subjectId, 
                                                           @PathVariable("fixedWeek") String fixedWeek, 
                                                           Model model) {
        knFixLsn001Dao.deleteByKeys(stuId, subjectId, fixedWeek);
        return ResponseEntity.ok("Success");
    }
}