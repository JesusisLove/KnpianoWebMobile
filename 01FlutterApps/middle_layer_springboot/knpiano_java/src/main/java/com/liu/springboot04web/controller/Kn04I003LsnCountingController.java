package com.liu.springboot04web.controller;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.liu.springboot04web.bean.Kn04I003LsnCountingBean;
import com.liu.springboot04web.dao.Kn04I003lsnCountingDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

@Controller
public class Kn04I003LsnCountingController {
    final List<String> knYear; 
    final List<String> knMonth;
    @Autowired
    private Kn04I003lsnCountingDao dao;

    public Kn04I003LsnCountingController(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框，过滤掉"ALL"
        List<String> allMonths = combListInfo.getMonths();
        this.knMonth = allMonths.stream()
                            .filter(month -> !"ALL".equals(month))
                            .collect(Collectors.toList());
}

    @GetMapping("/kn_lsn_counting")
    public String list(Model model) {

        LocalDate currentDate = LocalDate.now();// 获取当前日期
        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM");
        String currentYear = currentDate.format(formatter).substring(0, 4);
        String monthFrom = currentYear + "-01";
        String monthTo = currentDate.format(formatter);
        Collection<Kn04I003LsnCountingBean> collection = dao.getStuLsnCount(monthFrom, monthTo);
        model.addAttribute("infoList", collection);

        // 初期化Web页面的筛选条件，从当前年度的1月份到系统月份。
        model.addAttribute("currentyear", currentYear);
        model.addAttribute("knyearlist", knYear);

        // 月份下拉列表框初期化前台页面
        String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("MM"));
        model.addAttribute("currentmonth", currentMonth);
        model.addAttribute("knmonthlist", knMonth);
        return "kn_04i002_lsn_counting/kn04i002_lsn_counting_list";
    }

    // 【検索部】検索ボタンを押下
    @GetMapping("/kn_lsn_counting/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        String year = (String) queryParams.get("year");
        String monthFrom = year + "-" + String.format("%02d", Integer.parseInt((String) queryParams.get("monthFrom")));
        String monthTo = year + "-" + String.format("%02d", Integer.parseInt((String) queryParams.get("monthTo")));
        
        Collection<Kn04I003LsnCountingBean> collection = dao.getStuLsnCount(monthFrom, monthTo);
        model.addAttribute("infoList", collection);

        // 把画面传过来的参数返回给画面继续保持画面当前的筛选条件
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("lsnCountingMap", backForwordMap);
        
        // 添加必要的下拉列表数据（这里之前缺少了）
        model.addAttribute("knyearlist", knYear);
        model.addAttribute("knmonthlist", knMonth);
        
        return "kn_04i002_lsn_counting/kn04i002_lsn_counting_list";
    }
}