package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnStudoc001Bean;
import com.liu.springboot04web.dao.KnStudoc001Dao;
import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.service.ComboListInfoService;
import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.dao.KnStu001Dao;
import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.dao.KnSub001Dao;

import org.springframework.format.annotation.DateTimeFormat;
import java.util.Date;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Service
public class KnStudoc001Controller {
    private ComboListInfoService combListInfo;

    @Autowired
    private KnStudoc001Dao knStudoc001Dao;
    @Autowired
    private KnStu001Dao knStu001Dao;
    @Autowired
    private KnSub001Dao knSub001Dao;

    // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
    public KnStudoc001Controller(ComboListInfoService combListInfo) {
        this.combListInfo = combListInfo;
    }

    // 【KNPiano后台维护 学生档案管理】ボタンをクリック
    @GetMapping("/kn_studoc_001_all")
    public String list(Model model) {
        // 学生固定排课一览取得
        Collection<KnStudoc001Bean> collection = knStudoc001Dao.getInfoList();
        model.addAttribute("stuDocList", collection);
        return "kn_studoc_001/knstudoc001_list";
    }

    // 【検索一覧】検索ボタンを押下
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

    // 【検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_studoc_001")
    public String toStuDocAdd(Model model) {

        // 从学生基本信息表里，把学生名取出来，初期化新规/变更画面的学生下拉列表框
        model.addAttribute("stuMap", getStuCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("subMap", getSubCodeValueMap());

        final List<String> durations = combListInfo.getMinutesPerLsn();
        model.addAttribute("duration",durations );

        return "kn_studoc_001/knstudoc001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_studoc_001")
    public String executeStuDocAdd(KnStudoc001Bean knStudoc001Bean) {
        knStudoc001Dao.save(knStudoc001Bean);
        return "redirect:/kn_studoc_001_all";
    }

    // 【検索一覧】編集ボタンを押下
    @GetMapping("/kn_studoc_001/{stuId}/{subjectId}/{adjustedDate}")
    public String toStuDocEdit(@PathVariable("stuId") String stuId, 
                                    @PathVariable("subjectId") String subjectId, 
                                    @PathVariable ("adjustedDate") 
                                    @DateTimeFormat(pattern = "yyyy-MM-dd") // 从html页面传过来的字符串日期转换成可以接受的Date类型日期
                                    Date adjustedDate, 
                                    Model model) {
        KnStudoc001Bean knStudoc001Bean = knStudoc001Dao.getInfoByKey(stuId, subjectId, adjustedDate);
        model.addAttribute("selectedStuDoc", knStudoc001Bean);
        final List<String> durations = combListInfo.getMinutesPerLsn();
        model.addAttribute("duration",durations );
        return "kn_studoc_001/knstudoc001_add_update";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_studoc_001")
    public String executeStuDocEdit(KnStudoc001Bean knStudoc001Bean) {
        System.out.println("编辑固定授業計画: " + knStudoc001Bean);
        knStudoc001Dao.save(knStudoc001Bean);
        return "redirect:/kn_studoc_001_all";
    }

    // 【検索一覧】削除ボタンを押下
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