package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.dao.Kn02F004PayDao;
import com.liu.springboot04web.othercommon.CommonProcess;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
@Controller
public class Kn02F004PayController{
    final List<String> knYear; 
    final List<String> knMonth;
    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn02F004PayBean> lsnFeeStuList;

    @Autowired
    Kn02F004PayDao knLsnPay001Dao;
    
    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap;
    public Kn02F004PayController(ComboListInfoService combListInfo) {
        // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
        // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
        backForwordMap = new HashMap<>();
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();
        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
        this.lsnFeeStuList = null;
    }

    // 【課費支払管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_lsn_pay_001_all")
    public String list(@RequestParam Map<String, Object> queryParams, Model model) {
        // 未结算一览
        Collection<Kn02F004PayBean> paiedCollection = knLsnPay001Dao.searchLsnPay(queryParams);
        this.lsnFeeStuList = paiedCollection;  
        model.addAttribute("infoList",paiedCollection);
        // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("lsnfeestuList", lsnFeeStuList);
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

    @GetMapping("/kn_lsn_pay_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 把画面传来的年和月拼接成yyyy-mm的        
        Map<String, Object> params = new HashMap<>();
        String lsnMonth = (String) queryParams.get("selectedmonth");
        int month = Integer.parseInt(lsnMonth); // 将月份转换为整数类型
        lsnMonth = String.format("%02d", month); // 格式化为两位数并添加前导零
        params.put("pay_month", queryParams.get("selectedyear") + "-" + lsnMonth);
        // params.put("lsnfee.stu_id", queryParams.get("stuId"));
        params.put("stu_id", queryParams.get("stuId"));

        // 精算済一览
        Map<String, Object> collectionparams = CommonProcess.convertToSnakeCase(params);
        Collection<Kn02F004PayBean> paiedCollection = knLsnPay001Dao.searchLsnPay(collectionparams);      
        model.addAttribute("infoList",paiedCollection);
        // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("lsnfeestuList", lsnFeeStuList);
        // 回传参数设置（画面检索部的查询参数）
        backForwordMap.putAll(queryParams);
        model.addAttribute("payMap", backForwordMap);

        // 获取当前系统年份
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

    // 【課費精算管理】削除ボタンを押下して、当該情報を削除すること
    @DeleteMapping("/kn_lsn_pay_001/{lsnPayId}/{lsnFeeId}")
    public String undoLsnPay(@PathVariable("lsnPayId") String lsnPayId, @PathVariable("lsnFeeId") String lsnFeeId) {
        knLsnPay001Dao.excuteUndoLsnPay(lsnPayId, lsnFeeId);
        return "redirect:/kn_lsn_pay_001_all";
    }

        // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn02F004PayBean> collection) {

        Map<String, String> activeStudentsMap = new HashMap<>();
        Set<String> seenStuIds = new HashSet<>();

        for (Kn02F004PayBean bean : collection) {
            String stuId = bean.getStuId();
            if (!seenStuIds.contains(stuId)) {
                activeStudentsMap.put(stuId, bean.getStuName());
                seenStuIds.add(stuId);
            }
        }
        return activeStudentsMap;
    }
}
