package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.dao.KnSub001Dao;

import java.util.Collection;

@Controller
public class KnSub001Controller {

    @Autowired
    private KnSub001Dao knSub001Dao;

    // 显示所有学习科目信息
    @GetMapping("/kn_sub_001_all")
    public String list(Model model) {
        Collection<KnSub001Bean> collection = knSub001Dao.getInfoList();
        model.addAttribute("subjectList", collection);
        return "kn_sub_001/knsub001_list";
    }

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
