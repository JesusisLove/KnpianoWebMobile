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
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import com.liu.springboot04web.bean.Kn01L002ExtraToScheBean;
import com.liu.springboot04web.dao.Kn01L003ExtraPiesesIntoOneDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

@Controller
@Service
public class Kn01L003ExtraPiesesIntoOneController {

    final List<String> knYear; 
    final List<String> knMonth;

    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn01L002ExtraToScheBean> extra2ScheStuList;
    @Autowired
    private Kn01L003ExtraPiesesIntoOneDao kn01L003ExtraPiesesIntoOneDao;

    public Kn01L003ExtraPiesesIntoOneController(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
        this.extra2ScheStuList = null;
    }

    // 根据Web页面上年度和月份的下拉列表框的变化，实现学生姓名下拉列表框的联动初期化
    @GetMapping("/kn_pieses_into_one/{year}")
    public String list(@PathVariable("year") String year, Model model) {
        List<Kn01L002ExtraToScheBean> list = kn01L003ExtraPiesesIntoOneDao.getSearchInfo4Stu(year);
        model.addAttribute("extra2ScheStuList", list);

        // 创建 Map 并添加到 Model
        Map<String, String> extra2ScheMap = new HashMap<>();
        extra2ScheMap.put("selectedyear", year);
        model.addAttribute("extra2ScheMap", extra2ScheMap);

        model.addAttribute("knyearlist", knYear);
        model.addAttribute("knmonthlist", knMonth);

        return "kn_lsn_extra_pieses_into_one/kn_extra_pieces_list";
    }

    // 根据Web页面上的检索部传过来的年月，取得有加课的学生番号，学生姓名。初期化页面的学生姓名下拉列表框
    @GetMapping("/kn_pieses_into_one")
    public String list(Model model) {

        // 画面检索条件保持变量初始化前端检索部
        LocalDate currentDate = LocalDate.now();// 获取当前日期

        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy");
        String year = currentDate.format(formatter);
        Collection<Kn01L002ExtraToScheBean> collection = kn01L003ExtraPiesesIntoOneDao.getExtraPiesesLsnList(year, null);
        extra2ScheStuList = collection;
        model.addAttribute("infoList", collection);

        /* 初始化画面检索部 */
        // 把要消化加课的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("extra2ScheStuList", extra2ScheStuList);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collection);
        model.addAttribute("resultsTabStus", resultsTabStus);

        // 年度下拉列表框初期化前台页面
        model.addAttribute("knyearlist", knYear);

        return "kn_lsn_extra_pieses_into_one/kn_extra_pieces_list";
    }

    // 根据Web页面上的检索部传过来的年月，取得有零碎加课的学生番号，学生姓名。初期化页面的学生姓名下拉列表框
    @GetMapping("/kn_pieses_into_one/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        String lsnYear = (String) queryParams.get("selectedyear");
        String stuId = (String) queryParams.get("stuId");

        List<Kn01L002ExtraToScheBean> list = kn01L003ExtraPiesesIntoOneDao.getExtraPiesesLsnList(lsnYear, stuId);
        model.addAttribute("infoList", list);
        // 初始化Web页面学生姓名的下拉列表框
        model.addAttribute("extra2ScheStuList", extra2ScheStuList);

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);

        // 创建 Map 并添加到 Model
        // Map<String, String> extra2ScheMap = new HashMap<>();
        // extra2ScheMap.put("selectedyear", lsnYear);
        model.addAttribute("extra2ScheMap", backForwordMap);
        model.addAttribute("currentyear", lsnYear);
        model.addAttribute("knyearlist", knYear);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(list);
        model.addAttribute("resultsTabStus", resultsTabStus);

        return "kn_lsn_extra_pieses_into_one/kn_extra_pieces_list";
    }


    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
        private Map<String, String> getResultsTabStus(Collection<Kn01L002ExtraToScheBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();
        
        // 填充临时Map
        for (Kn01L002ExtraToScheBean bean : collection) {
            tempMap.putIfAbsent(bean.getStuId(), bean.getStuName());
        }
        
        // 按值（学生姓名）排序并收集到新的LinkedHashMap中
        return tempMap.entrySet()
                .stream()
                .sorted(Map.Entry.comparingByValue())
                .collect(Collectors.toMap(
                    Map.Entry::getKey,
                    Map.Entry::getValue,
                    (oldValue, newValue) -> oldValue,  // 处理重复键的情况
                    LinkedHashMap::new  // 使用LinkedHashMap保持排序
                ));
    }

}
