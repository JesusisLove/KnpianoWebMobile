package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnFixfLsn001Bean;
import com.liu.springboot04web.dao.KnFixfLsn001Dao;
import com.liu.springboot04web.othercommon.CommonProcess;

import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.dao.KnStu001Dao;
import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.dao.KnSub001Dao;


import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@Controller
public class KnFixfLsn001Controller {

    @Autowired
    private KnFixfLsn001Dao knFixfLsn001Dao;
    @Autowired
    private KnStu001Dao knStu001Dao;
    @Autowired
    private KnSub001Dao knSub001Dao;

    // 初始化显示所有固定授業計画信息
    @GetMapping("/kn_fixflsn_001_all")
    public String list(Model model) {
        // 学生固定排课一览取得
        Collection<KnFixfLsn001Bean> collection = knFixfLsn001Dao.getInfoList();
        model.addAttribute("fixedLessonList", collection);
        return "kn_fixflsn_001/knfixflsn001_list";
    }

    /** 画面检索 模糊检索功能追加  开始 */ 
    @GetMapping("/kn_fixflsn_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("fixedLessonMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如: stuId改成stu_id
           目的是，这个Map要传递到KnFixfLsn001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<KnFixfLsn001Bean> searchResults = knFixfLsn001Dao.searchFixedLessons(conditions);
        model.addAttribute("fixedLessonList", searchResults);
        return "/kn_fixflsn_001/knfixflsn001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }
    /** 画面检索 检索功能追加  结束 */ 

    // 「固定授業新規登録」ボタンをクリックして、跳转到新增固定授業計画的页面
    @GetMapping("/kn_fixflsn_001")
    public String toFixedLessonAdd(Model model) {

        // 从学生基本信息表里，把学生名取出来，初期化新规/变更画面的学生下拉列表框
        model.addAttribute("stuMap", getStuCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("subMap", getSubCodeValueMap());

        return "/kn_fixflsn_001/knfixflsn001_add_update";
    }

    // 保存新增的固定授業計画
    @PostMapping("/kn_fixflsn_001")
    public String executeFixedLessonAdd(KnFixfLsn001Bean knFixfLsn001Bean) {
        System.out.println("新增固定授業計画: " + knFixfLsn001Bean);
        knFixfLsn001Dao.save(knFixfLsn001Bean);
        return "redirect:/kn_fixflsn_001_all";
    }

    // 「変更」ボタンをクリックして、跳转到编辑固定授業計画的页面
    @GetMapping("/kn_fixflsn_001/{stuId}/{subjectId}/{fixedWeek}")
    public String toFixedLessonEdit(@PathVariable("stuId") String stuId, 
                                    @PathVariable("subjectId") String subjectId, 
                                    @PathVariable("fixedWeek") String fixedWeek, 
                                    Model model) {
        KnFixfLsn001Bean knFixfLsn001Bean = knFixfLsn001Dao.getInfoByKey(stuId, subjectId, fixedWeek);
        model.addAttribute("selectedFixedLesson", knFixfLsn001Bean);
        return "/kn_fixflsn_001/knfixflsn001_add_update";
    }

    // 保存编辑后的固定授業計画
    @PutMapping("/kn_fixflsn_001")
    public String executeFixedLessonEdit(KnFixfLsn001Bean knFixfLsn001Bean) {
        System.out.println("编辑固定授業計画: " + knFixfLsn001Bean);
        knFixfLsn001Dao.save(knFixfLsn001Bean);
        return "redirect:/kn_fixflsn_001_all";
    }

    // 删除固定授業計画
    @DeleteMapping("/kn_fixflsn_001/{stuId}/{subjectId}/{fixedWeek}")
    public String executeFixedLessonDelete (@PathVariable("stuId") String stuId, 
                                            @PathVariable("subjectId") String subjectId, 
                                            @PathVariable("fixedWeek") String fixedWeek, 
                                            Model model) {
        knFixfLsn001Dao.deleteByKeys(stuId, subjectId, fixedWeek);
        return "redirect:/kn_fixflsn_001_all";
    }

    // 学生下拉列表框初期化
    private Map<String, String> getStuCodeValueMap() {
        Collection<KnStu001Bean> collection = knStu001Dao.getInfoList();

        Map<String, String> map = new HashMap<>();
        for (KnStu001Bean bean : collection) {
            map.put(bean.getStuId(), bean.getStuName());
        }

        return map != null ? CommonProcess.sortMapByValues(map) : map;
    }

    // 科目下拉列表框初期化
    private Map<String, String> getSubCodeValueMap() {
        Collection<KnSub001Bean> collection = knSub001Dao.getInfoList();

        Map<String, String> map = new HashMap<>();
        for (KnSub001Bean bean : collection) {
            map.put(bean.getSubjectId(), bean.getSubjectName());
        }

        return map != null ? CommonProcess.sortMapByValues(map) : map;
    }
}