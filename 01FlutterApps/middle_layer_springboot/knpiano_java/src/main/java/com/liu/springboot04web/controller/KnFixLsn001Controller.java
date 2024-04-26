package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import com.liu.springboot04web.bean.KnFixLsn001Bean;
import com.liu.springboot04web.dao.KnFixLsn001Dao;
import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.service.ComboListInfoService;
import com.liu.springboot04web.bean.KnStu001Bean;
import com.liu.springboot04web.dao.KnStu001Dao;
import com.liu.springboot04web.bean.KnSub001Bean;
import com.liu.springboot04web.dao.KnSub001Dao;


import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

@Controller
@Service
public class KnFixLsn001Controller {
    private ComboListInfoService combListInfo;
    private String activeDay;

    @Autowired
    private KnFixLsn001Dao knFixLsn001Dao;
    @Autowired
    private KnStu001Dao knStu001Dao;
    @Autowired
    private KnSub001Dao knSub001Dao;
    
    public KnFixLsn001Controller(ComboListInfoService combListInfo) {
        this.combListInfo = combListInfo;
    }

    // 【KNPiano后台维护 固定课时信息】ボタンをクリック
    @GetMapping("/kn_fixlsn_001_all")
    public String list(Model model) {
        // 学生固定排课一览取得
        Collection<KnFixLsn001Bean> searchResults = knFixLsn001Dao.getInfoList();
        model.addAttribute("fixedLessonList", searchResults);

        List<String> resultsDays = CommonProcess.sortWeekdays(getResultsDays(searchResults));
        model.addAttribute("resultsDays", resultsDays);
        model.addAttribute("activeDay", (this.activeDay!=null)? this.activeDay : "Mon");

        return "kn_fixlsn_001/knfixlsn001_list";
    }

    // 【検索一覧】検索ボタンを押下
    @GetMapping("/kn_fixlsn_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("fixedLessonMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如: stuId改成stu_id
           目的是，这个Map要传递到KnFixLsn001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<KnFixLsn001Bean> searchResults = knFixLsn001Dao.searchFixedLessons(conditions);
        model.addAttribute("fixedLessonList", searchResults);

        List<String> resultsDays = CommonProcess.sortWeekdays(getResultsDays(searchResults));
        model.addAttribute("resultsDays", resultsDays);
        // 学生一周有复数天的排课，则默认显示第一个卡片（从Mon到Sun）
        model.addAttribute("activeDay", resultsDays.get(0));

        return "kn_fixlsn_001/knfixlsn001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_fixlsn_001")
    public String toFixedLessonAdd(Model model) {

        // 从学生基本信息表里，把学生名取出来，初期化新规/变更画面的学生下拉列表框
        model.addAttribute("stuMap", getStuCodeValueMap());
        // 从科目基本信息表里，把科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("subMap", getSubCodeValueMap());

        final List<String> regularWeek = combListInfo.getRegularWeek();
        model.addAttribute("regularweek",regularWeek );
        final List<String> regularHour = combListInfo.getRegularHour();
        model.addAttribute("regularhour",regularHour );
        final List<String> regularMinute = combListInfo.getRegularMinute();
        model.addAttribute("regularminute",regularMinute );

        return "kn_fixlsn_001/knfixlsn001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_fixlsn_001")
    public String executeFixedLessonAdd(KnFixLsn001Bean knFixLsn001Bean, Model model) {
        System.out.println("新增固定授業計画: " + knFixLsn001Bean);
        knFixLsn001Dao.save(knFixLsn001Bean);
        this.activeDay = knFixLsn001Bean.getFixedWeek();
        return "redirect:/kn_fixlsn_001_all";
    }

    // 【検索一覧】編集ボタンを押下
    @GetMapping("/kn_fixlsn_001/{stuId}/{subjectId}/{fixedWeek}")
    public String toFixedLessonEdit(@PathVariable("stuId") String stuId, 
                                    @PathVariable("subjectId") String subjectId, 
                                    @PathVariable("fixedWeek") String fixedWeek, 
                                    Model model) {
        KnFixLsn001Bean knFixLsn001Bean = knFixLsn001Dao.getInfoByKey(stuId, subjectId, fixedWeek);
        model.addAttribute("selectedFixedLesson", knFixLsn001Bean);

        final List<String> regularWeek = combListInfo.getRegularWeek();
        model.addAttribute("regularweek",regularWeek );

        final List<String> regularHour = combListInfo.getRegularHour();
        model.addAttribute("regularhour",regularHour );

        final List<String> regularMinute = combListInfo.getRegularMinute();
        model.addAttribute("regularminute",regularMinute );
        model.addAttribute("activeDay",knFixLsn001Bean.getFixedWeek() );

        return "kn_fixlsn_001/knfixlsn001_add_update";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_fixlsn_001")
    public String executeFixedLessonEdit(KnFixLsn001Bean knFixLsn001Bean, Model model) {
        System.out.println("编辑固定授業計画: " + knFixLsn001Bean);
        knFixLsn001Dao.save(knFixLsn001Bean);
        this.activeDay = knFixLsn001Bean.getFixedWeek();

        return "redirect:/kn_fixlsn_001_all";
    }

    // 【検索一覧】削除ボタンを押下
    @DeleteMapping("/kn_fixlsn_001/{stuId}/{subjectId}/{fixedWeek}")
    public String executeFixedLessonDelete (@PathVariable("stuId") String stuId, 
                                            @PathVariable("subjectId") String subjectId, 
                                            @PathVariable("fixedWeek") String fixedWeek, 
                                            Model model) {
        knFixLsn001Dao.deleteByKeys(stuId, subjectId, fixedWeek);
        this.activeDay = fixedWeek;
        return "redirect:/kn_fixlsn_001_all";
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

    private List<String> getResultsDays(Collection<KnFixLsn001Bean> collection) {

        List<String> activeDaysList = new ArrayList<>();
        for (KnFixLsn001Bean bean : collection) {
            activeDaysList.add(bean.getFixedWeek());
        }
        return CommonProcess.removeDuplicates(activeDaysList) ;
    }
}