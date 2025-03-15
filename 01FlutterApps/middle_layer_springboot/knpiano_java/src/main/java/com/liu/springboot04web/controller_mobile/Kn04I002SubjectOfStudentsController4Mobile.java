package com.liu.springboot04web.controller_mobile;

import java.util.Collection;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn03D002SubBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn04I002SubjectOfStudentsDao;

@RestController
@Service
public class Kn04I002SubjectOfStudentsController4Mobile {

    @Autowired
    Kn04I002SubjectOfStudentsDao dao;

    // 手机前端取得目前最新的所有科目
    @GetMapping("/mb_kn_subject_eda_stu_all")
    public ResponseEntity<Collection<Kn03D002SubBean>> getLatestSubjectsList() {
        // 获取休学学生信息
        Collection<Kn03D002SubBean> collection = dao.getInfoList();
        return ResponseEntity.ok(collection);
    }


    // 手机前端取得目前该科目下所有子科目正在上课的学生信息
    @GetMapping("/mb_kn_subject_sub_stu/{subjectId}")
    public ResponseEntity<Collection<Kn03D004StuDocBean>> getSubjectOfStudentsList(@PathVariable("subjectId") String subjectId) {
        // 获取休学学生信息
        final Collection<Kn03D004StuDocBean> collection = dao.getSubjectListOfStudents(subjectId);
        return ResponseEntity.ok(collection);
    }

}
