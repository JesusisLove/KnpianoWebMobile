package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnBnk001Bean;
import com.liu.springboot04web.dao.KnBnk001Dao;
import com.liu.springboot04web.othercommon.CamelCaseToSnakeCase;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@Controller
public class KnBnk001Controller {

    @Autowired
    private KnBnk001Dao knBnk001Dao;

    // 画面初期化显示所有银行信息
    @GetMapping("/kn_bnk_001_all")
    public String list(Model model) {
        Collection<KnBnk001Bean> collection = knBnk001Dao.getInfoList();
        model.addAttribute("bankList", collection);
        return "kn_bnk_001/knbnk001_list";
    }

    /** 画面检索 检索功能追加  开始 */ 
    @GetMapping("//kn_bnk_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("bankMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CamelCaseToSnakeCase.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<KnBnk001Bean> searchResults = knBnk001Dao.searchBanks(conditions);
        model.addAttribute("bankList", searchResults);
        return "kn_bnk_001/knbnk001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }
    /** 画面检索 检索功能追加  结束 */ 

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
