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

import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.bean.Kn05S001LsnFixBean;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;
import com.liu.springboot04web.dao.Kn05S001LsnFixDao;
import java.util.Collection;
import java.util.List;

@RestController
public class Kn05S001LsnFixController4Mobile {

    @Autowired
    Kn05S001LsnFixDao knFixLsn001Dao;
    @Autowired
    private Kn03D004StuDocDao kn03D002StuDocDao;

    // @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_fixlsn_001_all")
    public ResponseEntity<Collection<Kn05S001LsnFixBean>> getStudentList() {
        // 获取当前正在上课的所有学生信息
        Collection<Kn05S001LsnFixBean> collection = knFixLsn001Dao.getInfoList();
        return ResponseEntity.ok(collection);
    }

    // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来
    // @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_fixlsn_stusub_get")
    private ResponseEntity<Collection<Kn03D004StuDocBean>> getStuSubList() {
        List<Kn03D004StuDocBean> list = kn03D002StuDocDao.getLatestSubjectList();
        return ResponseEntity.ok(list);
    }

    // 【新規登録/変更編集】画面にて、【保存】ボタンを押下
    // @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_fixlsn_001")
    public void excuteInfoAdd(@RequestBody Kn05S001LsnFixBean knFixLsn001Bean) {
        // 因为是复合主键，只能通过从表里抽出记录来确定是新规操作还是更新操作
        boolean addNewMode = false;
        if (knFixLsn001Dao.getInfoByKey(knFixLsn001Bean.getStuId(), 
                                        knFixLsn001Bean.getSubjectId(), 
                                        knFixLsn001Bean.getFixedWeek()) == null) {
            // 前端画面在数据校验的时候，需要知道从后端传来的是新规登录模式还是变更编辑模式
            addNewMode = true;
        }
        knFixLsn001Dao.save(knFixLsn001Bean, addNewMode);
    }

    // 【排课一覧】削除ボタンを押下
    // @CrossOrigin(origins = "*") 
    @DeleteMapping("/mb_kn_fixlsn_001/{stuId}/{subjectId}/{fixedWeek}")
    public ResponseEntity<String> executeFixedLessonDelete(@PathVariable("stuId") String stuId, 
                                                           @PathVariable("subjectId") String subjectId, 
                                                           @PathVariable("fixedWeek") String fixedWeek, 
                                                           Model model) {
        knFixLsn001Dao.deleteByKeys(stuId, subjectId, fixedWeek);
        return ResponseEntity.ok("Success");
    }
}