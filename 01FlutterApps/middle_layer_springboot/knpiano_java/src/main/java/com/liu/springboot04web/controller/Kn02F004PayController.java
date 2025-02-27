package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.dao.Kn02F004PayDao;
// import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Controller
public class Kn02F004PayController{
    final List<String> knYear; 
    final List<String> knMonth;
    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn02F004PayBean> paidStuList;

    @Autowired
    Kn02F004PayDao knLsnPay001Dao;

    // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
    public Kn02F004PayController(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
        this.paidStuList = null;
    }

    // 【课费已支付管理】按钮按下，全ての情報を表示すること
    @GetMapping("/kn_lsn_pay_001_all")
    public String list(Model model) {
        // 课费已经结算完毕一览
        LocalDate currentDate = LocalDate.now();// 获取当前日期

        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy");
        String year = currentDate.format(formatter);

        Collection<Kn02F004PayBean> paiedCollection = knLsnPay001Dao.getInfoList(year);
        this.paidStuList = paiedCollection;  
        model.addAttribute("infoList",paiedCollection);

        // 把已付费的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("paidStuList", paidStuList);

        // 年度下拉列表框初期化前台页面
        int currentYear = Year.now().getValue();
        model.addAttribute("currentyear", currentYear);
        model.addAttribute("knyearlist", knYear);

        // 月份下拉列表框初期化前台页面
        String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("MM"));
        model.addAttribute("currentmonth", currentMonth);
        model.addAttribute("knmonthlist", knMonth);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(paiedCollection);
        model.addAttribute("resultsTabStus", resultsTabStus);

        return "kn_lsn_pay_001/knlsnpay001_list";
    }

    // 【检索部】検索ボタンを押下
    @GetMapping("/kn_lsn_pay_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 把画面传来的年和月拼接成yyyy-mm的        
        Map<String, Object> params = new HashMap<>();
        String lsnMonth = (String) queryParams.get("selectedmonth");
        String lsnYear = (String) queryParams.get("selectedyear");
        if ( !("ALL".equals(lsnMonth))) {
            int month = Integer.parseInt(lsnMonth); // 将月份转换为整数类型
            lsnMonth = String.format("%02d", month); // 格式化为两位数并添加前导零
            params.put("pay_month", queryParams.get("selectedyear") + "-" + lsnMonth);
        } else {
            params.put("pay_month", queryParams.get("selectedyear"));
        }

        // 检索条件
        params.put("stu_id", queryParams.get("stuId"));

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("payMap", backForwordMap);
        model.addAttribute("currentyear", lsnYear);
        model.addAttribute("knyearlist", knYear);
        model.addAttribute("currentmonth", lsnMonth);
        model.addAttribute("knmonthlist", knMonth);
        // 把已付费的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("paidStuList", paidStuList);

        Collection<Kn02F004PayBean> paiedCollection = knLsnPay001Dao.searchLsnPay(params);      
        model.addAttribute("infoList",paiedCollection);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(paiedCollection);
        model.addAttribute("resultsTabStus", resultsTabStus);
       
        return "kn_lsn_pay_001/knlsnpay001_list";
    }

    // 【課費精算管理】撤销ボタンを押下して、当該情報を引き戻すこと
    @DeleteMapping("/kn_lsn_pay_001/{lsnPayId}/{lsnFeeId}/{payMonth}")
    public String undoLsnPay(@PathVariable("lsnPayId") String lsnPayId, 
                             @PathVariable("lsnFeeId") String lsnFeeId,
                             @PathVariable("payMonth") String payMonth
                             ) {
        knLsnPay001Dao.excuteUndoLsnPay(lsnPayId, lsnFeeId, payMonth);
        return "redirect:/kn_lsn_pay_001_all";
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
