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

import com.liu.springboot04web.bean.Kn01L002ExtraHasBeenScheBean;
import com.liu.springboot04web.dao.Kn01L002ExtraHasBeenScheDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

@Controller
@Service
public class Kn01L002ExtraHasBeenScheController {
    final List<String> knYear; 
    final List<String> knMonth;

    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn01L002ExtraHasBeenScheBean> extra2ScheStuList;
    @Autowired
    private Kn01L002ExtraHasBeenScheDao dao;

    public Kn01L002ExtraHasBeenScheController(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
        this.extra2ScheStuList = null;
    }


    // 根据Web页面上年度和月份的下拉列表框的变化，实现学生姓名下拉列表框的联动初期化
    @GetMapping("/kn_extra_hasbeen_sche_all/{year}")
    public String list(@PathVariable("year") String year, Model model) {

        List<Kn01L002ExtraHasBeenScheBean> list = dao.getSearchInfo4Stu(year);
        model.addAttribute("extra2ScheStuList", list);

        // 创建 Map 并添加到 Model
        Map<String, String> extra2ScheMap = new HashMap<>();
        extra2ScheMap.put("selectedyear", year);
        model.addAttribute("extra2ScheMap", extra2ScheMap);

        model.addAttribute("knyearlist", knYear);
        model.addAttribute("knmonthlist", knMonth);

        return "kn_extra_been_sche_001/kn_extra_hasbeen_sche_list";
    }

    
    // 【KNPiano后台维护】点击“加课已换正课”画面初期化
    @GetMapping("/kn_extra_hasbeen_sche_all")
    public String list(Model model) {
        // 画面检索条件保持变量初始化前端检索部
        LocalDate currentDate = LocalDate.now();// 获取当前日期

        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy");
        String year = currentDate.format(formatter);

        // 用保持变量里的检索条件从DB里抽取数据
        Collection<Kn01L002ExtraHasBeenScheBean> collection = dao.getExcrHasBeenScheInfo(null, year, null);
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
        
        // 月份下拉列表框初期化前台页面
        String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("MM"));
        model.addAttribute("currentmonth", currentMonth);
        model.addAttribute("knmonthlist", knMonth);

        return "kn_extra_been_sche_001/kn_extra_hasbeen_sche_list";
    }

        // 【一覧画面検索部】検索ボタンを押下
    @GetMapping("/kn_extra_hasbeen_sche_all/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 把画面传来的年和月拼接成yyyy-mm的        
        String lsnYear = (String) queryParams.get("selectedyear");
        // 安全地转换Integer参数
        Integer isGoodChange = null;
        String isGoodChangeStr = (String) queryParams.get("isGoodChange");
        if (isGoodChangeStr != null && !isGoodChangeStr.trim().isEmpty()) {
            try {
                isGoodChange = Integer.valueOf(isGoodChangeStr);
            } catch (NumberFormatException e) {
                // 转换失败时保持为null，或设置默认值
                System.out.println("isGoodChange参数转换失败: " + isGoodChangeStr);
                isGoodChange = null;
            }
        }
        List<Kn01L002ExtraHasBeenScheBean> list = dao.getSearchInfo4Stu(lsnYear);
        model.addAttribute("extra2ScheStuList", list);

        // 检索条件
        String stuId = (String)queryParams.get("stuId");

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("extra2ScheMap", backForwordMap);
        // model.addAttribute("currentyear", lsnYear);
        model.addAttribute("knyearlist", knYear);
        model.addAttribute("knmonthlist", knMonth);

        // 将queryParams传递给Service层或Mapper接口
        Collection<Kn01L002ExtraHasBeenScheBean> searchResults = dao.getExcrHasBeenScheInfo(stuId, lsnYear,isGoodChange);
        model.addAttribute("infoList", searchResults);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(searchResults);
        model.addAttribute("resultsTabStus", resultsTabStus);
        return "kn_extra_been_sche_001/kn_extra_hasbeen_sche_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn01L002ExtraHasBeenScheBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();
        
        // 填充临时Map9
        for (Kn01L002ExtraHasBeenScheBean bean : collection) {
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
