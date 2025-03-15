package com.liu.springboot04web.controller;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.liu.springboot04web.bean.Kn02F003AdvcLsnFeePayBean;
import com.liu.springboot04web.bean.Kn03D002SubBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn04I002SubjectOfStudentsDao;

@Controller
public class Kn04I002SubjectOfStudentsController {

    @Autowired
    private Kn04I002SubjectOfStudentsDao dao;


    @GetMapping("/kn_subject_eda_stu_all")
    public String list(Model model) {

        Collection<Kn03D002SubBean> collection = dao.getInfoList();
        model.addAttribute("subjectInfoList", collection);

        return "kn_subject_sub_student/knsubjectofstu_list";
    }

    // 点击Web页面上的【推算排课日期】按钮
    @GetMapping("/kn_subject_sub_stu/search")
    public String search(@RequestParam Map<String, Object> queryParams, 
                                       Model model) {

        String subjectId = (String) queryParams.get("subjectId");

        if (!validateHasError(model,queryParams,null)) {
            // 将学生交费信息响应送给前端
            List<Kn03D004StuDocBean> list = dao.getSubjectListOfStudents(subjectId);
            model.addAttribute("infoList",list);

            // 利用resultsTabStus的学生名，在前端页面做Tab
            Map<String, String> resultsTabStus = getResultsTabStus(list);
            model.addAttribute("resultsTabStus", resultsTabStus);
        }

        Map<String, Object> backForwordMap = new HashMap<>();
        // 回传参数设置（画面检索部的查询参数）
        backForwordMap.putAll(queryParams);
        model.addAttribute("subjectPayMap", backForwordMap);

        // 画面初期化基本设定
        setModel(model);

        return "kn_subject_sub_student/knsubjectofstu_list";
    }


    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn03D004StuDocBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();
        
        // 填充临时Map
        for (Kn03D004StuDocBean bean : collection) {
            tempMap.putIfAbsent(bean.getSubjectSubId(), bean.getSubjectSubName());
        }
        
        // 按值（学生姓名）排序并收集到新的LinkedHashMap中
        return tempMap.entrySet()
                .stream()
                .sorted(Map.Entry.comparingByValue())
                .collect(Collectors.toMap(
                    Map.Entry::getKey,
                    Map.Entry::getValue,
                    (oldValue, newValue) -> oldValue,  // 处理重复键的情况
                    LinkedHashMap::new  // 使用LinkedHashMap保持排序
                ));
    }
    
    // 画面科目下拉列表初始化
    private void setModel(Model model) {
        Collection<Kn03D002SubBean> collection = dao.getInfoList();
        model.addAttribute("subjectInfoList", collection);
    }

    private boolean validateHasError(Model model, Map<String, Object> queryParams, Kn02F003AdvcLsnFeePayBean bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(queryParams, bean, msgList);
        if (hasError == true) {
            // 将学生交费信息响应送给前端
            model.addAttribute("selectedinfo", bean);

            // 将错误消息显示在画面上
            model.addAttribute("errorMessageList", msgList);
        }

        return hasError;
    }

    private boolean inputDataHasError(Map<String, Object> queryParams,Kn02F003AdvcLsnFeePayBean bean, List<String> msgList) {
        
        if (queryParams != null) {
            String subjectId = (String)queryParams.get("subjectId");
            if (subjectId.isEmpty()) {
                msgList.add("请选择科目。");

            }
        }
        return (msgList.size() != 0);
    }
}
