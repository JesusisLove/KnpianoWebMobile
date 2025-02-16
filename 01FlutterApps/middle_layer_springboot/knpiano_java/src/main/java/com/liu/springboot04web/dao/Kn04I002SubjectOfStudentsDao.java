package com.liu.springboot04web.dao;

import java.util.List;

import com.liu.springboot04web.bean.Kn03D002SubBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;

public interface Kn04I002SubjectOfStudentsDao {

    // 手机前端、Web页面
    public List<Kn03D002SubBean> getInfoList();
    public List<Kn03D004StuDocBean> getSubjectListOfStudents(String subjectId );

}