package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnBnk001Bean;
import com.liu.springboot04web.dao.KnBnk001Dao;

import java.util.Collection;

@Controller
public class KnBnk001Controller {

    @Autowired
    private KnBnk001Dao knBnk001Dao;

    // 显示所有银行信息
    @GetMapping("/kn_bnk_001_all")
    public String list(Model model) {
        Collection<KnBnk001Bean> collection = knBnk001Dao.getInfoList();
        model.addAttribute("bankList", collection);
        return "kn_bnk_001/knbnk001_list";
        // return "kn_sub_001/knsub001_list";
    }

    // 跳转到添加银行信息的页面
    @GetMapping("/kn_bnk_001")
    public String toBankAdd(Model model) {
        return "kn_bnk_001/knbnk001_add_update";
    }

    // 保存新增银行信息
    @PostMapping("/kn_bnk_001")
    public String executeBankAdd(KnBnk001Bean knBnk001Bean) {
        knBnk001Dao.save(knBnk001Bean);
        return "redirect:/kn_bnk_001_all";
    }

    // 跳转到编辑银行信息的页面
    @GetMapping("/kn_bnk_001/{id}")
    public String toBankEdit(@PathVariable("id") String id, Model model) {
        KnBnk001Bean knBnk001Bean = knBnk001Dao.getInfoById(id);
        model.addAttribute("selectedBank", knBnk001Bean);
        return "kn_bnk_001/knbnk001_add_update";
    }

    // 保存编辑后的银行信息
    @PutMapping("/kn_bnk_001")
    public String executeBankEdit(KnBnk001Bean knBnk001Bean) {
        knBnk001Dao.save(knBnk001Bean);
        return "redirect:/kn_bnk_001_all";
    }

    // 删除银行信息
    @DeleteMapping("/kn_bnk_001/{id}")
    public String executeBankDelete(@PathVariable("id") String id) {
        knBnk001Dao.delete(id);
        return "redirect:/kn_bnk_001_all";
    }
}
