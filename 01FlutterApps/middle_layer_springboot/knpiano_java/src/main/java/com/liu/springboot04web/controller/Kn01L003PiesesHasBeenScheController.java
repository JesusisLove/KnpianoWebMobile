package com.liu.springboot04web.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import com.liu.springboot04web.bean.Kn01L003ExtraPicesesBean;
import com.liu.springboot04web.dao.Kn01L003PiesesHasBeenScheDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

@Controller
@Service
public class Kn01L003PiesesHasBeenScheController {

    final List<String> knYear;
    // final List<String> knMonth;

    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn01L003ExtraPicesesBean> extra2ScheStuList;
    @Autowired
    private Kn01L003PiesesHasBeenScheDao kn01L003PiesesHasBeenScheDao;


    public Kn01L003PiesesHasBeenScheController(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        // this.knMonth = combListInfo.getMonths();
        this.extra2ScheStuList = null;
    }


    // 页面初期化
    @GetMapping("/kn_pieses_hasbeen_sche")
    public String list(Model model) {

        // 画面检索条件保持变量初始化前端检索部
        LocalDate currentDate = LocalDate.now();// 获取当前日期

        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy");
        String year = currentDate.format(formatter);
        Collection<Kn01L003ExtraPicesesBean> collectionNew = kn01L003PiesesHasBeenScheDao.getPicesesHasBeenScheLsnList(year,
                null);
        extra2ScheStuList = collectionNew;
        model.addAttribute("infoListPiceseHasBeenSche", collectionNew);

        Collection<Kn01L003ExtraPicesesBean> collectionOld = kn01L003PiesesHasBeenScheDao.getExtraPicesesIntoOneLsnList(year,
                null);
        model.addAttribute("infoListPicesExtra", collectionOld);

        // TODO 还要看课费支付表，对于已经结算完了的课，就让撤销按钮不可用。（课费结算完了，不能撤销）


        /* 初始化画面检索部 */
        // 把要消化加课的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("extra2ScheStuList", extra2ScheStuList);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collectionNew);
        model.addAttribute("resultsTabStus", resultsTabStus);

        // 年度下拉列表框初期化前台页面
        model.addAttribute("knyearlist", knYear);

        return "kn_lsn_extra_pis_hsbn_sche/kn_pis_hsbn_sche_list";
    }


    // 选择年度切换，初始化该年度下的学生姓名下拉列表框
    @GetMapping("/kn_pieses_hasbeen_sche/{year}")
    public String list(@PathVariable("year") String year, Model model) {
        List<Kn01L003ExtraPicesesBean> list = kn01L003PiesesHasBeenScheDao.getPicesesHasBeenScheLsnList(year,null);
        model.addAttribute("extra2ScheStuList", list);

        // 创建 Map 并添加到 Model
        Map<String, String> extra2ScheMap = new HashMap<>();
        extra2ScheMap.put("selectedyear", year);
        model.addAttribute("extra2ScheMap", extra2ScheMap);

        model.addAttribute("knyearlist", knYear);
        // model.addAttribute("knmonthlist", knMonth);

        return "kn_lsn_extra_pis_hsbn_sche/kn_pis_hsbn_sche_list";
    }


    // 检索该年度，该学生的零碎课数据
    @GetMapping("/kn_pieses_hasbeen_sche/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        String lsnYear = (String) queryParams.get("selectedyear");
        String stuId = (String) queryParams.get("stuId");

        Collection<Kn01L003ExtraPicesesBean> collectionNew = kn01L003PiesesHasBeenScheDao.getPicesesHasBeenScheLsnList(lsnYear,
                stuId);
        model.addAttribute("infoListPiceseHasBeenSche", collectionNew);

        Collection<Kn01L003ExtraPicesesBean> collectionOld = kn01L003PiesesHasBeenScheDao.getExtraPicesesIntoOneLsnList(lsnYear,
                stuId);
        model.addAttribute("infoListPicesExtra", collectionOld);

        // TODO 还要看课费支付表，对于已经结算完了的课，就让撤销按钮不可用。（课费结算完了，不能撤销）


        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);

        model.addAttribute("extra2ScheMap", backForwordMap);
        model.addAttribute("currentyear", lsnYear);
        model.addAttribute("knyearlist", knYear);

         // 另外，pullDownlist结果集里还有科目和该科目一节课的课程时长的信息。用于碎课拼整课的计算和判断。
        model.addAttribute("extra2ScheStuList", extra2ScheStuList);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collectionNew);
        model.addAttribute("resultsTabStus", resultsTabStus);

        return "kn_lsn_extra_pis_hsbn_sche/kn_pis_hsbn_sche_list";
    }
    

    // 对零碎加课已经换正课的记录执行撤销
    @PostMapping("/kn_revoke_assembled_lesson")
    @Transactional(rollbackFor = Exception.class)
    public String undoAssembledLesson(@RequestParam Map<String, Object> queryParams, Model model) {
        // String year = (String) queryParams.get("selectedyear");
        // String stuId = (String) queryParams.get("stuId");
        String lessonId = (String) queryParams.get("lessonId");

        try {

            // 从零碎课拼凑整课转换正课中间表，取出零碎加课的课程编号（old_lesson_id)
            List<String> lsnIdsList = kn01L003PiesesHasBeenScheDao.getOldLessonIds(lessonId);
            for (String oldLsnId : lsnIdsList) {
                // 更新课程表零碎课的逻辑删除flg（set del_flg = 0)，恢复成零碎课的状态：更新条件： old_lesson_id
                kn01L003PiesesHasBeenScheDao.undoLogicalDelLesson(oldLsnId);
                kn01L003PiesesHasBeenScheDao.undoLogicalDelLsnFee(oldLsnId);
            }

            kn01L003PiesesHasBeenScheDao.deletePiesHsbnScheFee(lessonId);

            // 物理删除课程表掉拼凑整课转正课的课程记录。删除条件：lesson_id
            kn01L003PiesesHasBeenScheDao.deletePiesHsbnSche(lessonId);

            // 物理删除整课转正课中间表的课程关联记录：删除条件：lesson_id
            kn01L003PiesesHasBeenScheDao.deletePiceseExtraIntoOne(lessonId);

        } catch (Exception e)  {
            e.printStackTrace();
        }
        
        return "redirect:/kn_pieses_hasbeen_sche";
    }


    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn01L003ExtraPicesesBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();

        // 填充临时Map
        for (Kn01L003ExtraPicesesBean bean : collection) {
            tempMap.putIfAbsent(bean.getStuId(), bean.getStuName());
        }

        // 按值（学生姓名）排序并收集到新的LinkedHashMap中
        return tempMap.entrySet()
                .stream()
                .sorted(Map.Entry.comparingByValue())
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (oldValue, newValue) -> oldValue, // 处理重复键的情况
                        LinkedHashMap::new // 使用LinkedHashMap保持排序
                ));
    }

}
