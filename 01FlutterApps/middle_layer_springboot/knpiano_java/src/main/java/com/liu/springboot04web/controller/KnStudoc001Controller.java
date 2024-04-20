package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnStudoc001Bean;
import com.liu.springboot04web.dao.KnStudoc001Dao;
import com.liu.springboot04web.othercommon.CommonProcess;

import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.dao.KnStu001Dao;
import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.dao.KnSub001Dao;

import org.springframework.format.annotation.DateTimeFormat;
import java.util.Date;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@Controller
public class KnStudoc001Controller {

    @Autowired
    private KnStudoc001Dao knStudoc001Dao;
    @Autowired
    private KnStu001Dao knStu001Dao;
    @Autowired
    private KnSub001Dao knSub001Dao;

    // 初始化显示所有固定授業計画信息
    @GetMapping("/kn_studoc_001_all")
    public String list(Model model) {
        // 学生固定排课一览取得
        Collection<KnStudoc001Bean> collection = knStudoc001Dao.getInfoList();
        model.addAttribute("stuDocList", collection);
        return "kn_studoc_001/knstudoc001_list";
    }

    /** 画面检索 模糊检索功能追加  开始 */ 
    @GetMapping("/kn_studoc_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("stuDocMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如: stuId改成stu_id
           目的是，这个Map要传递到KnStudoc001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<KnStudoc001Bean> searchResults = knStudoc001Dao.searchStuDoc(conditions);
        model.addAttribute("stuDocList", searchResults);
        return "kn_studoc_001/knstudoc001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }
    /** 画面检索 检索功能追加  结束 */ 

    // 「学生档案新規登録」ボタンをクリックして、跳转到新增固定授業計画的页面
    @GetMapping("/kn_studoc_001")
    public String toStuDocAdd(Model model) {

        // 从学生基本信息表里，把学生名取出来，初期化新规/变更画面的学生下拉列表框
        model.addAttribute("stuMap", getStuCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("subMap", getSubCodeValueMap());

        return "kn_studoc_001/knstudoc001_add_update";
    }

    // 保存新增的固定授業計画
    @PostMapping("/kn_studoc_001")
    public String executeStuDocAdd(KnStudoc001Bean knStudoc001Bean) {
        // System.out.println("新增固定授業計画: " + knStudoc001Bean);
        knStudoc001Dao.save(knStudoc001Bean);
        return "redirect:/kn_studoc_001_all";
    }

    // 「変更」ボタンをクリックして、跳转到编辑固定授業計画的页面
    @GetMapping("/kn_studoc_001/{stuId}/{subjectId}/{adjustedDate}")
    public String toStuDocEdit(@PathVariable("stuId") String stuId, 
                                    @PathVariable("subjectId") String subjectId, 
                                    @PathVariable ("adjustedDate") 
                                    @DateTimeFormat(pattern = "yyyy-MM-dd") // 从html页面传过来的字符串日期转换成可以接受的Date类型日期
                                    Date adjustedDate, 
                                    Model model) {
        KnStudoc001Bean knStudoc001Bean = knStudoc001Dao.getInfoByKey(stuId, subjectId, adjustedDate);
        model.addAttribute("selectedStuDoc", knStudoc001Bean);
        return "kn_studoc_001/knstudoc001_add_update";
    }

    // 保存编辑后的固定授業計画
    @PutMapping("/kn_studoc_001")
    public String executeStuDocEdit(KnStudoc001Bean knStudoc001Bean) {
        System.out.println("编辑固定授業計画: " + knStudoc001Bean);
        knStudoc001Dao.save(knStudoc001Bean);
        return "redirect:/kn_studoc_001_all";
    }

    // 删除固定授業計画
    @DeleteMapping("/kn_studoc_001/{stuId}/{subjectId}/{adjustedDate}")
    public String executeStuDocDelete (@PathVariable("stuId") String stuId, 
                                            @PathVariable("subjectId") String subjectId, 
                                            @PathVariable("adjustedDate") 
                                            @DateTimeFormat(pattern = "yyyy-MM-dd") // 从html页面传过来的字符串日期转换成可以接受的Date类型日期
                                            Date adjustedDate, 
                                            Model model) {
        knStudoc001Dao.deleteByKeys(stuId, subjectId, adjustedDate);
        return "redirect:/kn_studoc_001_all";
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
    private Map<String, Object> getSubCodeValueMap() {
        Collection<KnSub001Bean> collection = knSub001Dao.getInfoList();

        Map<String, Object> map = new HashMap<>();
        for (KnSub001Bean bean : collection) {
            map.put(bean.getSubjectId(), bean);
        }
        return map;
    }
}