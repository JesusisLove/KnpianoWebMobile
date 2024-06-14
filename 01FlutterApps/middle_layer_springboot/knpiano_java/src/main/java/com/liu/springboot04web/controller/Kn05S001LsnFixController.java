package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn03D002StuDocBean;
import com.liu.springboot04web.bean.Kn05S001LsnFixBean;
import com.liu.springboot04web.dao.Kn03D002StuDocDao;
import com.liu.springboot04web.dao.Kn05S001LsnFixDao;
import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.service.ComboListInfoService;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;

@Controller
@Service
public class Kn05S001LsnFixController {
    private ComboListInfoService combListInfo;
    private String activeDay;

    @Autowired
    private Kn05S001LsnFixDao knFixLsn001Dao;
    @Autowired
    private Kn03D002StuDocDao kn03D002StuDocDao;
    
    public Kn05S001LsnFixController(ComboListInfoService combListInfo) {
        this.combListInfo = combListInfo;
    }

    // 【KNPiano后台维护 固定课时信息】ボタンをクリック
    @GetMapping("/kn_fixlsn_001_all")
    public String list(Model model) {
        // 学生固定排课一览取得
        Collection<Kn05S001LsnFixBean> searchResults = knFixLsn001Dao.getInfoList();
        model.addAttribute("fixedLessonList", searchResults);

        List<String> resultsTabDays = CommonProcess.sortWeekdays(getResultsTabDays(searchResults));
        model.addAttribute("resultsTabDays", resultsTabDays);
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
        Collection<Kn05S001LsnFixBean> searchResults = knFixLsn001Dao.searchFixedLessons(conditions);
        model.addAttribute("fixedLessonList", searchResults);

        List<String> resultsTabDays = CommonProcess.sortWeekdays(getResultsTabDays(searchResults));
        model.addAttribute("resultsTabDays", resultsTabDays);
        // 学生一周有复数天的排课，则默认显示第一个卡片（从Mon到Sun）
        model.addAttribute("activeDay", resultsTabDays.get(0));

        return "kn_fixlsn_001/knfixlsn001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【検索一覧】新規登録ボタンを押下
    @GetMapping("/kn_fixlsn_001")
    public String toFixedLessonAdd(Model model) {

        // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("stuSubList", getStuSubList());

        // 初期化星期下拉列表框
        final List<String> regularWeek = combListInfo.getRegularWeek();
        model.addAttribute("regularweek",regularWeek );

        // 初期化固定上课时间几点的下拉列表框
        final List<String> regularHour = combListInfo.getRegularHour();
        model.addAttribute("regularhour",regularHour );
        
        // 初期化固定上课时间几分的下拉列表框
        final List<String> regularMinute = combListInfo.getRegularMinute();
        model.addAttribute("regularminute",regularMinute );

        return "kn_fixlsn_001/knfixlsn001_add_update";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_fixlsn_001")
    public String executeFixedLessonAdd(Kn05S001LsnFixBean knFixLsn001Bean, Model model) {
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
        Kn05S001LsnFixBean knFixLsn001Bean = knFixLsn001Dao.getInfoByKey(stuId, subjectId, fixedWeek);
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
    public String executeFixedLessonEdit(Kn05S001LsnFixBean knFixLsn001Bean, Model model) {
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

    // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来
    private List<Kn03D002StuDocBean> getStuSubList() {
        List<Kn03D002StuDocBean> list = kn03D002StuDocDao.getLatestSubjectList();
        return list;
    }

    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private List<String> getResultsTabDays(Collection<Kn05S001LsnFixBean> collection) {

        List<String> activeDaysList = new ArrayList<>();
        for (Kn05S001LsnFixBean bean : collection) {
            activeDaysList.add(bean.getFixedWeek());
        }
        return CommonProcess.removeDuplicates(activeDaysList) ;
    }
}