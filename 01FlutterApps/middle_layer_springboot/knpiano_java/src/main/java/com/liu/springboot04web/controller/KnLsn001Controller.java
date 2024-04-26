package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.KnLsn001Bean;
import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.dao.KnLsn001Dao;
import com.liu.springboot04web.dao.KnStu001Dao;
import com.liu.springboot04web.dao.KnSub001Dao;
import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.service.ComboListInfoService;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Service
public class KnLsn001Controller{
    private final ComboListInfoService combListInfo;

    @Autowired
    private KnLsn001Dao knLsn001Dao;
    @Autowired
    private KnStu001Dao knStu001Dao;
    @Autowired
    private KnSub001Dao knSub001Dao;
    
    // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
    public KnLsn001Controller(ComboListInfoService combListInfo) {
        this.combListInfo = combListInfo;
    }

    // 【KNPiano后台维护 课程信息管理】ボタンをクリック
    @GetMapping("/kn_lsn_001_all")
    public String list(Model model) {
        Collection<KnLsn001Bean> collection = knLsn001Dao.getInfoList();
        model.addAttribute("infoList",collection);
        return "kn_lsn_001/knlsn001_list";
    }

    // 【検索一覧】検索ボタンを押下
    @GetMapping("/kn_lsn_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("lsnMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<KnLsn001Bean> searchResults = knLsn001Dao.searchLessons(conditions);
        model.addAttribute("infoList", searchResults);
        return "kn_lsn_001/knlsn001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_lsn_001")
    public String toInfoAdd(Model model) {

        // 从学生基本信息表里，把学生名取出来，初期化新规/变更画面的下拉列表框
        model.addAttribute("stuMap", getStuCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的下拉列表框
        model.addAttribute("subMap", getSubCodeValueMap());

        final List<String> durations = combListInfo.getDurations();
        model.addAttribute("duration",durations );
        return "kn_lsn_001/knlsn001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_lsn_001")
    public String excuteInfoAdd(KnLsn001Bean knLsn001Bean) {
        knLsn001Dao.save(knLsn001Bean);
        return "redirect:/kn_lsn_001_all";
    }

    // 【検索一覧】編集ボタンを押下
    @GetMapping("/kn_lsn_001/{id}")
    public String toInfoEdit(@PathVariable("id") String id, Model model) {
  
        KnLsn001Bean knLsn001Bean = knLsn001Dao.getInfoById(id);
        model.addAttribute("selectedinfo", knLsn001Bean);
        
        final List<String> durations = combListInfo.getDurations();
        model.addAttribute("duration", durations);
        return "kn_lsn_001/knlsn001_add_update";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_lsn_001")
    public String excuteInfoEdit(@ModelAttribute KnLsn001Bean knLsn001Bean) {
        knLsn001Dao.save(knLsn001Bean);
        return "redirect:/kn_lsn_001_all";
    }

    // 【検索一覧】削除ボタンを押下
    @DeleteMapping("/kn_lsn_001/{id}")
    public String excuteInfoDelete(@PathVariable("id") String id) {
        knLsn001Dao.delete(id);
        return "redirect:/kn_lsn_001_all";
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
