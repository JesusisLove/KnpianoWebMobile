package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.dao.KnSub001Dao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@Controller
public class KnSub001Controller {

    @Autowired
    private KnSub001Dao knSub001Dao;

    // 画面初期化显示所有学习科目信息
    @GetMapping("/kn_sub_001_all")
    public String list(Model model) {
        Collection<KnSub001Bean> collection = knSub001Dao.getInfoList();
        model.addAttribute("subjectList", collection);
        return "kn_sub_001/knsub001_list";
    }

    /** 画面检索 检索功能追加  开始 */ 
    @GetMapping("/kn_sub_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("subjectMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<KnSub001Bean> searchResults = knSub001Dao.searchSubjects(conditions);
        model.addAttribute("subjectList", searchResults);
        return "kn_sub_001/knsub001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }
    /** 画面检索 检索功能追加  结束 */ 

    // 跳转到添加科目的页面
    @GetMapping("/kn_sub_001")
    public String toSubjectAdd(Model model) {
        return "kn_sub_001/knsub001_add_update";
    }

    // 保存新增科目
    @PostMapping("/kn_sub_001")
    public String executeSubjectAdd(KnSub001Bean knSub001Bean) {
        System.out.println("新增科目: " + knSub001Bean);
        knSub001Dao.save(knSub001Bean);
        return "redirect:/kn_sub_001_all";
    }

    // 跳转到编辑科目的页面
    @GetMapping("/kn_sub_001/{id}")
    public String toSubjectEdit(@PathVariable("id") String id, Model model) {
        KnSub001Bean knSub001Bean = knSub001Dao.getInfoById(id);
        model.addAttribute("selectedSubject", knSub001Bean);
        return "kn_sub_001/knsub001_add_update";
    }

    // 保存编辑后的科目
    @PutMapping("/kn_sub_001")
    public String executeSubjectEdit(KnSub001Bean knSub001Bean) {
        System.out.println("编辑科目: " + knSub001Bean);
        knSub001Dao.save(knSub001Bean);
        return "redirect:/kn_sub_001_all";
    }

    // 删除科目
    @DeleteMapping("/kn_sub_001/{id}")
    public String executeSubjectDelete(@PathVariable("id") String id) {
        knSub001Dao.delete(id);
        return "redirect:/kn_sub_001_all";
    }
}
