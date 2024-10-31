package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn01L002ExtraToScheBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn01L002ExtraToScheDao;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;
import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.service.ComboListInfoService;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Controller
@Service
public class Kn01L002ExtraToScheController {
    @Autowired
    private Kn01L002ExtraToScheDao kn01L002ExtraToScheDao;
    @Autowired
    private Kn03D004StuDocDao kn03D002StuDocDao;

    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap;

    public Kn01L002ExtraToScheController(ComboListInfoService combListInfo) {
        // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
        backForwordMap = new HashMap<>();
    }

    // 【KNPiano后台维护 加课换正课处理】ボタンをクリック
    @GetMapping("/kn_extratosche_all")
    public String list(Model model) {
        // 画面检索条件保持变量初始化前端检索部
        model.addAttribute("lsnMap", backForwordMap);

        /*
         * 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
         * 目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件
         */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(this.backForwordMap);

        // 用保持变量里的检索条件从DB里抽取数据
        Collection<Kn01L002ExtraToScheBean> collection = kn01L002ExtraToScheDao.searchLessons(conditions);
        model.addAttribute("infoList", collection);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collection);
        model.addAttribute("resultsTabStus", resultsTabStus);

        return "kn_extra_to_sche_001/kn_extra_list";
    }

    // 【一覧画面検索部】検索ボタンを押下
    @GetMapping("/kn_extratosche_all/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 回传参数设置（画面检索部的查询参数）
        // Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("lsnMap", backForwordMap);

        /*
         * 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
         * 目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件
         */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<Kn01L002ExtraToScheBean> searchResults = kn01L002ExtraToScheDao.searchLessons(conditions);
        model.addAttribute("infoList", searchResults);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(searchResults);
        model.addAttribute("resultsTabStus", resultsTabStus);
        return "kn_extra_to_sche_001/kn_extra_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【一覧画面明细部】加课换正课ボタンを押下从检索画面迁移到加课换正课的详细信息画面
    @GetMapping("/kn_extra_lsn_detail/{lessonid}")
    public String toProcessExtraLsn(@PathVariable("lessonid") String lessonid, Model model) {
        Kn01L002ExtraToScheBean bean = kn01L002ExtraToScheDao.getExtraLsnDetail(lessonid);
        model.addAttribute("selectedinfo", bean);
        return "kn_extra_to_sche_001/knl_extra_change_to_sche";
    }

    // 执行加课换正课的业务处理（未结算的加课可以换成任何时候的正课，过去的正课，现在的正课，将来的正课）
    @GetMapping("/kn_extra_tobe_sche")
    public String doProcessExtraLsn(Kn01L002ExtraToScheBean kn01L002ExtraToScheBean, Model model) {

        // 画面数据有效性校验
        if (validateHasError(model, kn01L002ExtraToScheBean)) {
            return "kn_extra_to_sche_001/knl_extra_change_to_sche";
        }
        // 执行加课换正课处理
        kn01L002ExtraToScheDao.executeExtraToSche(kn01L002ExtraToScheBean);

        return "redirect:/kn_extratosche_all";
    }

    private boolean validateHasError(Model model, Kn01L002ExtraToScheBean knLsn001Bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(knLsn001Bean, msgList);
        if (hasError == true) {
            // 新规画面下拉列表框项目内容初始化
            model.addAttribute("stuSubList", getStuSubList());

            // 将错误消息显示在画面上
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedinfo", knLsn001Bean);
        }
        return hasError;
    }

    private boolean inputDataHasError(Kn01L002ExtraToScheBean knLsn001Bean, List<String> msgList) {
        if (knLsn001Bean.getExtraToDurDate() == null ) {
            msgList.add("请选定加课换正课的日期");
        }

        return (msgList.size() != 0);
    }

    //【一覧画面明细部】加课换正课撤销ボタンを押下
    @GetMapping("/kn_extra_lsn_undo/{lessonid}")
    public String lessonUndo(@PathVariable("lessonid") String lessonId, Model model) {
        // 执行加课换正课处理
        kn01L002ExtraToScheDao.undoExtraToSche(lessonId);
        return "redirect:/kn_extratosche_all";
    }

    // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来
    private List<Kn03D004StuDocBean> getStuSubList() {
        List<Kn03D004StuDocBean> list = kn03D002StuDocDao.getLatestSubjectList();
        return list;
    }

    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn01L002ExtraToScheBean> collection) {

        Map<String, String> activeStudentsMap = new HashMap<>();
        Set<String> seenStuIds = new HashSet<>();

        for (Kn01L002ExtraToScheBean bean : collection) {
            String stuId = bean.getStuId();
            if (!seenStuIds.contains(stuId)) {
                activeStudentsMap.put(stuId, bean.getStuName());
                seenStuIds.add(stuId);
            }
        }

        return activeStudentsMap;
    }

}
