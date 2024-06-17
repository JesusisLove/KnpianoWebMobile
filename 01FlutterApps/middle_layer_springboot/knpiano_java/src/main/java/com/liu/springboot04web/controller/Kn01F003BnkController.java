package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn01B003BnkBean;
import com.liu.springboot04web.dao.Kn01B003BnkDao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
public class Kn01F003BnkController {

    @Autowired
    private Kn01B003BnkDao knBnk001Dao;

    // 【KNPiano后台维护 银行账户信息】ボタンをクリック
    @GetMapping("/kn_bnk_001_all")
    public String list(Model model) {
        Collection<Kn01B003BnkBean> collection = knBnk001Dao.getInfoList();
        model.addAttribute("bankList", collection);
        return "kn_bnk_001/knbnk001_list";
    }

    // 【検索一覧】検索ボタンを押下
    @GetMapping("/kn_bnk_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("bankMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<Kn01B003BnkBean> searchResults = knBnk001Dao.searchBanks(conditions);
        model.addAttribute("bankList", searchResults);
        return "kn_bnk_001/knbnk001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_bnk_001")
    public String toBankAdd(Model model) {
        return "kn_bnk_001/knbnk001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_bnk_001")
    public String executeBankAdd(Model model, Kn01B003BnkBean knBnk001Bean) {
        // 画面数据有效性校验
        if (validateHasError(model, knBnk001Bean)) {
            return "kn_bnk_001/knbnk001_add_update";
        }  
        knBnk001Dao.save(knBnk001Bean);
        return "redirect:/kn_bnk_001_all";
    }

    // 【検索一覧】編集ボタンを押下
    @GetMapping("/kn_bnk_001/{id}")
    public String toBankEdit(@PathVariable("id") String id, Model model) {
        Kn01B003BnkBean knBnk001Bean = knBnk001Dao.getInfoById(id);
        model.addAttribute("selectedBank", knBnk001Bean);
        return "kn_bnk_001/knbnk001_add_update";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_bnk_001")
    public String executeBankEdit(Model model, Kn01B003BnkBean knBnk001Bean) {
        // 画面数据有效性校验
        if (validateHasError(model, knBnk001Bean)) {
            return "kn_bnk_001/knbnk001_add_update";
        } 
        knBnk001Dao.save(knBnk001Bean);
        return "redirect:/kn_bnk_001_all";
    }

    // 【検索一覧】削除ボタンを押下
    @DeleteMapping("/kn_bnk_001/{id}")
    public String executeBankDelete(@PathVariable("id") String id) {
        knBnk001Dao.delete(id);
        return "redirect:/kn_bnk_001_all";
    }

    private boolean validateHasError(Model model, Kn01B003BnkBean knStu001Bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(knStu001Bean, msgList);
        if (hasError == true) {
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedinfo", knStu001Bean);
        }
        return hasError;
    }

    private boolean inputDataHasError(Kn01B003BnkBean knStu001Bean, List<String> msgList) {
        if (knStu001Bean.getBankName()==null || knStu001Bean.getBankName().isEmpty() ) {
            msgList.add("请输入银行名称");
        }
        return (msgList.size() != 0);
    }
}
