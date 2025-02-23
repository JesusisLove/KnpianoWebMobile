package com.liu.springboot04web.controller;

import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.dao.KnErrorDataWatchDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

@Controller
public class KnErrorDataWatchController {
    final List<String> knYear; 
    // 把有错误数据的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn02F004PayBean> stuErrorDataList;

    @Autowired
    private KnErrorDataWatchDao errDataDao;

    // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
    public KnErrorDataWatchController(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        this.stuErrorDataList = null;
    }


    @GetMapping("/kn_err_watch")
    public String list(Model model) {
        // 课费已经结算完毕一览
        LocalDate currentDate = LocalDate.now();// 获取当前日期

        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy");
        String year = currentDate.format(formatter);

        // 年度下拉列表框初期化前台页面
        int currentYear = Year.now().getValue();
        model.addAttribute("currentyear", currentYear);
        model.addAttribute("knyearlist", knYear);

        stuErrorDataList = errDataDao.getErrDataList();
        model.addAttribute("infoList", stuErrorDataList);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(stuErrorDataList);
        model.addAttribute("resultsTabStus", resultsTabStus);
        return "watch_err_data/kn_errdata_list";
    }
    
        // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn02F004PayBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();
        
        // 填充临时Map
        for (Kn02F004PayBean bean : collection) {
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
