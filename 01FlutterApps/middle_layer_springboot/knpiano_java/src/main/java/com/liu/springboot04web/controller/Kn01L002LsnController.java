package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.constant.KNConstant;
import com.liu.springboot04web.dao.Kn01L002LsnDao;
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
public class Kn01L002LsnController{
    private final ComboListInfoService combListInfo;

    @Autowired
    private Kn01L002LsnDao knLsn001Dao;
    @Autowired
    private Kn03D004StuDocDao kn03D002StuDocDao;

    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap; 

    
    public Kn01L002LsnController(ComboListInfoService combListInfo) {
        // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
        this.combListInfo = combListInfo;

        // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
        backForwordMap = new HashMap<>();
    }

    // 【KNPiano后台维护 课程信息管理】ボタンをクリック
    @GetMapping("/kn_lsn_001_all")
    public String list(Model model) {
        // 画面检索条件保持变量初始化前端检索部
        model.addAttribute("lsnMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(this.backForwordMap);

        // 用保持变量里的检索条件从DB里抽取数据
        Collection<Kn01L002LsnBean> collection = knLsn001Dao.searchLessons(conditions);
        for (Kn01L002LsnBean bean:collection) {
            setButtonUsable(bean);
        }
        model.addAttribute("infoList",collection);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collection);
        model.addAttribute("resultsTabStus", resultsTabStus);

        return "kn_lsn_001/knlsn001_list";
    }

    // 【一覧画面検索部】検索ボタンを押下
    @GetMapping("/kn_lsn_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 回传参数设置（画面检索部的查询参数）
        // Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("lsnMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<Kn01L002LsnBean> searchResults = knLsn001Dao.searchLessons(conditions);
        for (Kn01L002LsnBean bean:searchResults) {
            setButtonUsable(bean);
        }
        model.addAttribute("infoList", searchResults);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(searchResults);
        model.addAttribute("resultsTabStus", resultsTabStus);
        return "kn_lsn_001/knlsn001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【一覧画面】新規登録ボタンを押下
    @GetMapping("/kn_lsn_001")
    public String toInfoAdd(Model model) {

        // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来，初期化新规/变更画面的科目下拉列表框
        model.addAttribute("stuSubList", getStuSubList());

        final List<String> durations = combListInfo.getDurations();
        model.addAttribute("duration",durations );
        return "kn_lsn_001/knlsn001_add_update";
    }

    // 【一覧画面明细部】編集ボタンを押下
    @GetMapping("/kn_lsn_001/{id}")
    public String toInfoEdit(@PathVariable("id") String id, Model model) {
  
        Kn01L002LsnBean knLsn001Bean = knLsn001Dao.getInfoById(id);
        model.addAttribute("selectedinfo", knLsn001Bean);
        
        final List<String> durations = combListInfo.getDurations();
        model.addAttribute("duration", durations);
        return "kn_lsn_001/knlsn001_add_update";
    }

    // 【一覧画面明细部】削除ボタンを押下
    @DeleteMapping("/kn_lsn_001/{id}")
    public String excuteInfoDelete(@PathVariable("id") String id) {
        knLsn001Dao.delete(id);
        return "redirect:/kn_lsn_001_all";
    }

    // 【一覧画面明细部】签到ボタンを押下
    @GetMapping("/kn_lsn_001_lsn_sign/{lessonid}")
    public String lessonSign(@PathVariable("lessonid") String id, Model model) {
        // 拿到该课程信息
        Kn01L002LsnBean knLsn001Bean = knLsn001Dao.getInfoById(id);
        
        // 执行签到
        knLsn001Dao.excuteSign(knLsn001Bean);
        return "redirect:/kn_lsn_001_all";
    }

    // 【一覧画面明细部】撤销ボタンを押下
    @GetMapping("/kn_lsn_001_lsn_undo/{lessonid}")
    public String lessonUndo(@PathVariable("lessonid") String id, Model model) {
    
        // 拿到该课程信息
        Kn01L002LsnBean knLsn001Bean = knLsn001Dao.getInfoById(id);
        // 撤销签到登记
        knLsn001Dao.excuteUndo(knLsn001Bean);
        return "redirect:/kn_lsn_001_all";
    }

    // 【新規登録】画面にて、【保存】ボタンを押下
    @PostMapping("/kn_lsn_001")
    public String excuteInfoAdd(Model model, Kn01L002LsnBean knLsn001Bean) {
        // 画面数据有效性校验
        if (validateHasError(model, knLsn001Bean)) {
            return "kn_lsn_001/knlsn001_add_update";
        }
        knLsn001Dao.save(knLsn001Bean);
        return "redirect:/kn_lsn_001_all";
    }

    // 【変更編集】画面にて、【保存】ボタンを押下
    @PutMapping("/kn_lsn_001")
    public String excuteInfoEdit(Model model, @ModelAttribute Kn01L002LsnBean knLsn001Bean) {
        // 画面数据有效性校验
        if (validateHasError(model, knLsn001Bean)) {
            return "kn_lsn_001/knlsn001_add_update";
        }
        knLsn001Dao.save(knLsn001Bean);
        return "redirect:/kn_lsn_001_all";
    }

    // 从学生档案信息表里，把已经开课了的学生姓名以及Ta正在上的科目名取出来
    private List<Kn03D004StuDocBean> getStuSubList() {
        List<Kn03D004StuDocBean> list = kn03D002StuDocDao.getLatestSubjectList();
        return list;
    }

    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn01L002LsnBean> collection) {

        Map<String, String> activeStudentsMap = new HashMap<>();
        Set<String> seenStuIds = new HashSet<>();

        for (Kn01L002LsnBean bean : collection) {
            String stuId = bean.getStuId();
            if (!seenStuIds.contains(stuId)) {
                activeStudentsMap.put(stuId, bean.getStuName());
                seenStuIds.add(stuId);
            }
        }

        return activeStudentsMap;
    }

    // 给后台页面上课一览明细部的按钮设置活性非活性状态
     public Kn01L002LsnBean setButtonUsable(Kn01L002LsnBean bean) {
        int lessonType = bean.getLessonType();
        boolean hasPlannedDate = bean.getSchedualDate() != null;
        boolean hasActualDate = bean.getScanQrDate() != null;
        boolean hasAdditionalToPlannedDate = bean.getExtraToDurDate() != null;

        // 初始化按钮状态
        bean.setUsableEdit(false);
        bean.setUsableDelete(false);
        bean.setUsableSign(false);
        bean.setUsableCancel(false);

        if (lessonType == KNConstant.CONSTANT_LESSON_TYPE_MONTHLY_SCHEDUAL 
            || lessonType == KNConstant.CONSTANT_LESSON_TYPE_TIAMLY) { // 计划课
            if (!hasActualDate) {
                // #1 未开始上课
                bean.setUsableEdit(true);
                bean.setUsableDelete(true);
                bean.setUsableSign(true);
                bean.setUsableCancel(false);
            } else if (hasPlannedDate && hasActualDate) {
                // 按照调课后的日期上课完了
                bean.setUsableEdit(false);
                bean.setUsableDelete(false);
                bean.setUsableSign(false);
                if (bean.isToday(bean.getScanQrDate())){
                    // 当日撤销可
                    bean.setUsableCancel(true);
                } else {
                    // 次日以后撤销不可
                    bean.setUsableCancel(false);
                }
            } 
        } else if (lessonType == KNConstant.CONSTANT_LESSON_TYPE_MONTHLY_ADDITIONAL) { // 追加课
            if (!hasActualDate && !hasAdditionalToPlannedDate) {
                bean.setUsableEdit(true);
                bean.setUsableDelete(true);
                bean.setUsableSign(true);
                bean.setUsableCancel(false);
            } else if (hasPlannedDate && hasActualDate && !hasAdditionalToPlannedDate) {
                bean.setUsableEdit(true);
                bean.setUsableDelete(false);
                bean.setUsableSign(false);
                if (bean.isToday(bean.getScanQrDate())){
                    // 当日撤销可
                    bean.setUsableCancel(true);
                } else {
                    // 次日以后撤销不可
                    bean.setUsableCancel(false);
                }
            } else if (hasPlannedDate  && hasActualDate && hasAdditionalToPlannedDate) {
                bean.setUsableEdit(true);
                bean.setUsableDelete(false);
                bean.setUsableSign(false);
                bean.setUsableCancel(false);
            } 
        }
        return bean;
    }

    private boolean validateHasError(Model model, Kn01L002LsnBean knLsn001Bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(knLsn001Bean, msgList);
        if (hasError == true) {
            // 新规画面下拉列表框项目内容初始化
            model.addAttribute("stuSubList", getStuSubList());

            final List<String> durations = combListInfo.getDurations();
            model.addAttribute("duration",durations );

            // 将错误消息显示在画面上
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedinfo", knLsn001Bean);
        }
        return hasError;
    }

    private boolean inputDataHasError(Kn01L002LsnBean knLsn001Bean, List<String> msgList) {
        if (knLsn001Bean.getStuId()==null || knLsn001Bean.getStuId().isEmpty() ) {
            msgList.add("请选择学生姓名");
        }

        if (knLsn001Bean.getSubjectId() == null || knLsn001Bean.getSubjectId().isEmpty()) {
            msgList.add("请选择科目名称");
        }

        if (knLsn001Bean.getSchedualDate() == null) {
            msgList.add("请选择计划上课日期");
        }

        if (knLsn001Bean.getClassDuration() == null || knLsn001Bean.getClassDuration() == 0) {
            msgList.add("请选择上课时长");
        }

        return (msgList.size() != 0);
    }
}
