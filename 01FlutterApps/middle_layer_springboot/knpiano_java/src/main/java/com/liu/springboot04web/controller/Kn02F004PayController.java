package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.dao.Kn02F004PayDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
        Collection<Kn02F004PayBean> unPaiedCollection = knLsnPay001Dao.searchLsnUnpay(queryParams);
        this.lsnFeeStuList = unPaiedCollection;  
        model.addAttribute("infoList",unPaiedCollection);
        // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("lsnfeestuList", lsnFeeStuList);
        // 年度下拉列表框初期化前台页面
        int currentYear = Year.now().getValue();
        model.addAttribute("currentyear", currentYear);
        model.addAttribute("knyearlist", knYear);
        model.addAttribute("knmonthlist", knMonth);

        return "kn_lsn_pay_001/knlsnpay001_list";
    }

    @GetMapping("/kn_lsn_pay_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 把画面传来的年和月拼接成yyyy-mm的        
        Map<String, Object> params = new HashMap<>();
        String lsnMonth = (String) queryParams.get("selectedmonth");
        int month = Integer.parseInt(lsnMonth); // 将月份转换为整数类型
        lsnMonth = String.format("%02d", month); // 格式化为两位数并添加前导零
        params.put("lsn_month", queryParams.get("selectedyear") + "-" + lsnMonth);
        params.put("lsnfee.stu_id", queryParams.get("stuId"));

        // 未结算一览
        // Map<String, Object> collectionparams = CommonProcess.convertToSnakeCase(params);
        Collection<Kn02F004PayBean> unPaiedCollection = knLsnPay001Dao.searchLsnUnpay(params);      
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

        return "kn_lsn_pay_001/knlsnpay001_list";
    }

    // 【課費支払管理】新規ボタンを押下して、【課費支払管理】新規画面へ遷移すること
    @GetMapping("/kn_lsn_pay_001")
    public String toInfoAdd(Model model) {
        return "kn_lsn_pay_001/knlsnpay001_add_update";
    }

    // 【課費支払管理】新規画面にて、【保存】ボタンを押下して、新規情報を保存すること
    @PostMapping("/kn_lsn_pay_001")
    public String excuteInfoAdd(Kn02F004PayBean knLsnPay001Bean) {
        knLsnPay001Dao.save(knLsnPay001Bean);
        return "redirect:/kn_lsn_pay_001_all";
    }

    // 【課費支払管理--未支付明细】支付学费ボタンを押下して、【課費支払管理】学费支付画面へ遷移すること
    @GetMapping("/kn_lsn_pay_001/{lsnFeeId}")
        public String toInfoEdit(@PathVariable("lsnFeeId") String lsnFeeId, 
                                  Model model) {
        // 根据课费编号，取得未支付的课费信息
        Kn02F004PayBean knLsnPay001Bean = knLsnPay001Dao.gethLsnUnpayByID(lsnFeeId);
        // 取得该生的银行信息
        String stuId = knLsnPay001Bean.getStuId();
        // 根据stuId从银行管理表，取得该学生使用的银行名称（复数个银行可能）

        // TODO
        model.addAttribute("bankList", "TODO 该生的学生名称");
        // 将学生交费信息响应送给前端
        model.addAttribute("selectedinfo", knLsnPay001Bean);
        return "kn_lsn_pay_001/knlsnpay001_add_update";
    }

    // // 【課費支払管理】編集画面にて、【保存】ボタンを押下して、変更した情報を保存すること
    // @PutMapping("/kn_lsn_pay_001")
    // public String excuteInfoEdit(@ModelAttribute Kn02F004PayBean knLsnPay001Bean) {
    //     knLsnPay001Dao.save(knLsnPay001Bean);
    //     return "redirect:/kn_lsn_pay_001_all";
    // }

    // // 【課費支払管理】削除ボタンを押下して、当該情報を削除すること
    // @DeleteMapping("/kn_lsn_pay_001/{lsnPayId}/{lsnFeeId}")
    // public String excuteInfoDelete(@PathVariable("lsnPayId") String lsnPayId, 
    //                                @PathVariable("lsnFeeId") String lsnFeeId) {
    //     knLsnPay001Dao.delete(lsnPayId, lsnFeeId);
    //     return "redirect:/kn_lsn_pay_001_all";
    // }
}
