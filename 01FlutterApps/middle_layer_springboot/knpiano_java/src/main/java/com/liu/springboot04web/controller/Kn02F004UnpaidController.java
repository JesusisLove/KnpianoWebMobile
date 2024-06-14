package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.bean.Kn02F004UnpaidBean;
import com.liu.springboot04web.bean.Kn05S002StubnkBean;
import com.liu.springboot04web.dao.Kn02F004UnpaidDao;
import com.liu.springboot04web.dao.Kn05S002StubnkDao;
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
public class Kn02F004UnpaidController{
    final List<String> knYear; 
    final List<String> knMonth;
    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn02F004UnpaidBean> lsnFeeStuList;

    @Autowired
    Kn05S002StubnkDao kn05S002StubnkDao;
    @Autowired
    Kn02F004UnpaidDao knLsnUnPaid001Dao;
    
    
    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap;
    public Kn02F004UnpaidController(ComboListInfoService combListInfo) {
        // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
        // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
        backForwordMap = new HashMap<>();

        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
        this.lsnFeeStuList = null;
    }

    // 【課費未支払管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_lsn_unpaid_001_all")
    public String list(@RequestParam Map<String, Object> queryParams, Model model) {
        // 未结算一览
        Collection<Kn02F004UnpaidBean> unPaiedCollection = knLsnUnPaid001Dao.searchLsnUnpay(queryParams);
        this.lsnFeeStuList = unPaiedCollection;  

        for (Kn02F004UnpaidBean kn02f004UnpaidBean : unPaiedCollection) {
            if (kn02f004UnpaidBean.getOwnFlg() == 1) {
                kn02f004UnpaidBean.setLsnFee(0);
            }
        }

        model.addAttribute("infoList",unPaiedCollection);

        // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("lsnfeestuList", lsnFeeStuList);

        // 年度下拉列表框初期化前台页面
        int currentYear = Year.now().getValue();
        model.addAttribute("currentyear", currentYear);
        model.addAttribute("knyearlist", knYear);
        model.addAttribute("knmonthlist", knMonth);

       // 利用resultsTabStus的学生名，在前端页面做Tab
       Map<String, String> resultsTabStus = getResultsTabStus(unPaiedCollection);
       model.addAttribute("resultsTabStus", resultsTabStus);
       
        return "kn_lsn_unpaid_001/knlsnunpaid001_list";
    }

    @GetMapping("/kn_lsn_unpaid_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 把画面传来的年和月拼接成yyyy-mm的        
        Map<String, Object> params = new HashMap<>();
        String lsnMonth = (String) queryParams.get("selectedmonth");
        int month = Integer.parseInt(lsnMonth); // 将月份转换为整数类型
        lsnMonth = String.format("%02d", month); // 格式化为两位数并添加前导零
        params.put("lsn_month", queryParams.get("selectedyear") + "-" + lsnMonth);
        params.put("lsnfee.stu_id", queryParams.get("stuId"));

        // 未结算一览
        Collection<Kn02F004UnpaidBean> unPaiedCollection = knLsnUnPaid001Dao.searchLsnUnpay(params);      
        model.addAttribute("infoList",unPaiedCollection);

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
        Map<String, String> resultsTabStus = getResultsTabStus(unPaiedCollection);
        model.addAttribute("resultsTabStus", resultsTabStus);
        
        return "kn_lsn_unpaid_001/knlsnunpaid001_list";
    }

    // 【課費未支払管理】学费精算ボタンを押下して、【課費未支払管理】学费支付画面へ遷移すること
    @GetMapping("/kn_lsn_unpaid_001/{lsnFeeId}")
    public String toLsnPay(@PathVariable("lsnFeeId") String lsnFeeId, 
                                  Model model) {
        // 根据课费编号，取得未支付的课费信息
        Kn02F004UnpaidBean knLsnUnPaid001Bean = knLsnUnPaid001Dao.gethLsnUnpayByID(lsnFeeId);

        // 取得该生的银行信息
        String stuId = knLsnUnPaid001Bean.getStuId();

        // 根据stuId从银行管理表，取得该学生使用的银行名称（复数个银行可能）
        Map<String, String> stuBankMap = getStuBnkCodeValueMap(stuId);
        model.addAttribute("bankMap", stuBankMap);

        // 将学生交费信息响应送给前端
        model.addAttribute("selectedinfo", knLsnUnPaid001Bean);
        return "kn_lsn_unpaid_001/knlsnunpaid001_add_update";
    }

    // 【課費未支払管理】精算画面にて、【保存】ボタンを押下して、課費精算を行うこと
    @PostMapping("/kn_lsn_unpaid_001")
    public String excuteLsnPay(Kn02F004UnpaidBean knLsnUnPaid001Bean) {
        // 課費精算を行う
        knLsnUnPaid001Dao.excuteLsnPay(knLsnUnPaid001Bean);
        return "redirect:/kn_lsn_unpaid_001_all";
    }

    // 学生银行下拉列表框初期化
    private Map<String, String> getStuBnkCodeValueMap(String stuId) {
        Collection<Kn05S002StubnkBean> collection = kn05S002StubnkDao.getInfoById(stuId);

        Map<String, String> map = new HashMap<>();
        for (Kn05S002StubnkBean bean : collection) {
            map.put(bean.getBankId(), bean.getBankName());
        }
        return map;
    }


    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn02F004UnpaidBean> collection) {

        Map<String, String> activeStudentsMap = new HashMap<>();
        Set<String> seenStuIds = new HashSet<>();

        for (Kn02F004UnpaidBean bean : collection) {
            String stuId = bean.getStuId();
            if (!seenStuIds.contains(stuId)) {
                activeStudentsMap.put(stuId, bean.getStuName());
                seenStuIds.add(stuId);
            }
        }
        return activeStudentsMap;
    }
}
