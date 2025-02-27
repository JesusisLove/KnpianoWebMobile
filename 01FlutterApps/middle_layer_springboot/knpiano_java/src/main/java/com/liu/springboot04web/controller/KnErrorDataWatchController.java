package com.liu.springboot04web.controller;

// import java.time.LocalDate;
// import java.time.Year;
// import java.time.format.DateTimeFormatter;
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

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.dao.KnErrorDataWatchDao;

@Controller
public class KnErrorDataWatchController {

    @Autowired
    KnErrorDataWatchDao errDataDao;

    @GetMapping("/kn_err_fee_watch")
    public String listErrFee(Model model) {
        List<Kn02F004PayBean> stuErrorDataList = errDataDao.getErrFeeDataList();
        model.addAttribute("infoList", stuErrorDataList);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsFeeTabStus(stuErrorDataList);
        model.addAttribute("resultsTabStus", resultsTabStus);
        return "watch_err_data/kn_err_fee_data_list";
    }

    @GetMapping("/kn_err_lsn_watch")
    public String listErrLsn(Model model) {
        List<Kn01L002LsnBean> stuErrorLsnList = errDataDao.getErrLsnDataList();
        model.addAttribute("infoList", stuErrorLsnList);

        List<Kn01L002LsnBean> stuErrorLsnGroupList = errDataDao.getErrLsnGroupDataList();
        model.addAttribute("infoGroupList", stuErrorLsnGroupList);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsLsnTabStus(stuErrorLsnList);
        model.addAttribute("resultsTabStus", resultsTabStus);
        return "watch_err_data/kn_err_lsn_data_list";
    }
    
    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsFeeTabStus(Collection<Kn02F004PayBean> collection) {
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

    private Map<String, String> getResultsLsnTabStus(Collection<Kn01L002LsnBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();
        
        // 填充临时Map
        for (Kn01L002LsnBean bean : collection) {
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
