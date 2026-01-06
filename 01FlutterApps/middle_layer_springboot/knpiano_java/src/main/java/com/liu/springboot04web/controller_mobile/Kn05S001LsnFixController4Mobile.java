package com.liu.springboot04web.controller_mobile;

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

    @GetMapping("/mb_kn_fixlsn_001_all")
    public ResponseEntity<Collection<Kn05S001LsnFixBean>> getStudentList() {
        // 获取当前正在上课的所有学生信息
        Collection<Kn05S001LsnFixBean> collection = knFixLsn001Dao.getInfoList();
        return ResponseEntity.ok(collection);
    }

    // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来
    @GetMapping("/mb_kn_fixlsn_stusub_get")
    private ResponseEntity<Collection<Kn03D004StuDocBean>> getStuSubList() {
        List<Kn03D004StuDocBean> list = kn03D002StuDocDao.getLatestSubjectList();
        return ResponseEntity.ok(list);
    }

    // 【新規登録/変更編集】画面にて、【保存】ボタンを押下
    @PostMapping("/mb_kn_fixlsn_001")
    public void excuteInfoAdd(@RequestBody Kn05S001LsnFixBean knFixLsn001Bean) {
        // 从请求体中获取原始星期几
        String originalFixedWeek = knFixLsn001Bean.getOriginalFixedWeek();

        // 判断是新增还是更新
        boolean addNewMode = false;
        if (originalFixedWeek == null || originalFixedWeek.isEmpty()) {
            // 如果没有原始星期几，说明是新增模式
            addNewMode = true;
        }

        // 调用修改后的save方法，传递原始星期几
        knFixLsn001Dao.save(knFixLsn001Bean, addNewMode, originalFixedWeek);
    }

    // 【排课一覧】削除ボタンを押下
    @DeleteMapping("/mb_kn_fixlsn_001/{stuId}/{subjectId}/{fixedWeek}")
    public ResponseEntity<String> executeFixedLessonDelete(@PathVariable("stuId") String stuId, 
                                                           @PathVariable("subjectId") String subjectId, 
                                                           @PathVariable("fixedWeek") String fixedWeek, 
                                                           Model model) {
        knFixLsn001Dao.deleteByKeys(stuId, subjectId, fixedWeek);
        return ResponseEntity.ok("Success");
    }
}