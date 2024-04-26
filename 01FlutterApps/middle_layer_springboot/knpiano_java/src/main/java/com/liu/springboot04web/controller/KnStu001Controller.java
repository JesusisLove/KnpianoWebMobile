package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.dao.KnStu001Dao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@Controller
public class KnStu001Controller{

    @Autowired
    KnStu001Dao knStu001Dao;

    // 【KNPiano后台维护 学生信息】ボタンをクリック
    @GetMapping("/kn_stu_001_all")
    public String list(Model model) {
        Collection<KnStu001Bean> collection = knStu001Dao.getInfoList();
        model.addAttribute("infoList",collection);
        // resources¥templates¥kn_stu_001¥knstu001_list.html
        return "kn_stu_001/knstu001_list";
    }

    // 【検索一覧】検索ボタンを押下
    @GetMapping("/kn_stu_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("studentMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<KnStu001Bean> searchResults = knStu001Dao.searchStudents(conditions);
        model.addAttribute("infoList", searchResults);
        return "kn_stu_001/knstu001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_stu_001")
    public String toInfoAdd(Model model) {
        return "kn_stu_001/knstu001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_stu_001")
    public String excuteInfoAdd(KnStu001Bean knStu001Bean) {
        System.out.println("" + knStu001Bean);
        knStu001Dao.save(knStu001Bean);
        return "redirect:/kn_stu_001_all";
    }

    // 【検索一覧】編集ボタンを押下
    @GetMapping("/kn_stu_001/{id}")
    public String toInfoEdit(@PathVariable("id") String id, Model model) {
        KnStu001Bean knStu001Bean = knStu001Dao.getInfoById(id);
        model.addAttribute("selectedinfo", knStu001Bean);
        return "kn_stu_001/knstu001_add_update";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_stu_001")
    public String excuteInfoEdit(@ModelAttribute KnStu001Bean knStu001Bean) {
        knStu001Dao.save(knStu001Bean);
        return "redirect:/kn_stu_001_all";
    }

    // 【検索一覧】削除ボタンを押下
    @DeleteMapping("/kn_stu_001/{id}")
    public String excuteInfoDelete(@PathVariable("id") String id) {
        knStu001Dao.delete(id);
        return "redirect:/kn_stu_001_all";
    }
}