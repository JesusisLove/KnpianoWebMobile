package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.liu.springboot04web.bean.Kn01B001StuBean;
import com.liu.springboot04web.dao.Kn01B001StuDao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class Kn01B001StuController{

    @Autowired
    Kn01B001StuDao knStu001Dao;

    // 【KNPiano后台维护 学生信息】ボタンをクリック
    @GetMapping("/kn_stu_001_all")
    public String list(Model model) {
        Collection<Kn01B001StuBean> collection = knStu001Dao.getInfoList();
        model.addAttribute("infoList",collection);
        // resources¥templates¥kn_stu_001¥knstu001_list.html
        return "kn_stu_001/knstu001_list";
    }

    // 【明细検索一覧】検索ボタンを押下
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
        Collection<Kn01B001StuBean> searchResults = knStu001Dao.searchStudents(conditions);
        model.addAttribute("infoList", searchResults);
        return "kn_stu_001/knstu001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【明细検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_stu_001")
    public String toInfoAdd(Model model) {
        return "kn_stu_001/knstu001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_stu_001")
    public String excuteInfoAdd(Model model, Kn01B001StuBean knStu001Bean) {

        // 画面数据有效性校验
        if (validateHasError(model, knStu001Bean)) {
            return "kn_stu_001/knstu001_add_update";
        }
        knStu001Dao.save(knStu001Bean);
        return "redirect:/kn_stu_001_all";
    }

    // 【明细検索一覧】編集ボタンを押下
    @GetMapping("/kn_stu_001/{id}")
    public String toInfoEdit(@PathVariable("id") String id, Model model) {
        Kn01B001StuBean knStu001Bean = knStu001Dao.getInfoById(id);
        model.addAttribute("selectedinfo", knStu001Bean);
        return "kn_stu_001/knstu001_add_update";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_stu_001")
    public String excuteInfoEdit(Model model, @ModelAttribute Kn01B001StuBean knStu001Bean) {
        // 画面数据有效性校验
        if (validateHasError(model, knStu001Bean)) {
            return "kn_stu_001/knstu001_add_update";
        }
        knStu001Dao.save(knStu001Bean);
        return "redirect:/kn_stu_001_all";
    }

    // 【明细検索一覧】削除ボタンを押下
    @DeleteMapping("/kn_stu_001/{id}")
    public String executeInfoDelete(@PathVariable("id") String id, RedirectAttributes redirectAttributes) {
        try {
            knStu001Dao.delete(id);
            return "redirect:/kn_stu_001_all";
        } catch (DataIntegrityViolationException e) {
            // 添加异常消息到重定向属性
            redirectAttributes.addFlashAttribute("errorMessage", "該当データ【"+id+"】が使用中です。削除できません。");
            return "redirect:/kn_stu_001_all"; // 重定向到列表页面
        }
    }

    private boolean validateHasError(Model model, Kn01B001StuBean knStu001Bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(knStu001Bean, msgList);
        if (hasError == true) {
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedinfo", knStu001Bean);
        }
        return hasError;
    }

    private boolean inputDataHasError(Kn01B001StuBean knStu001Bean, List<String> msgList) {
        if (knStu001Bean.getStuName()==null || knStu001Bean.getStuName().isEmpty() ) {
            msgList.add("请输入学生姓名");
        }

        if (knStu001Bean.getGender() == null) {
            msgList.add("请选择性别");
        }
        return (msgList.size() != 0);
    }
}