package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.liu.springboot04web.bean.Kn02F003LsnFeeAdvcPayBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn02F003LsnFeeAdvcPayDao;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;

// Kn02F003LsnFeeAdvcPayBean

@Controller
public class Kn02F003LsnFeeAdvcPayController {
    List<String> knYear = null; 
    List<String> knMonth = null;
    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    List<Kn03D004StuDocBean> lsnStuList;
    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap;

    @Autowired
    Kn02F003LsnFeeAdvcPayDao kn02F003LsnFeeAdvcPayDao;
    @Autowired
    Kn03D004StuDocDao kn03D004StuDocDao;

    public Kn02F003LsnFeeAdvcPayController(ComboListInfoService combListInfo) {
                // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
        // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
        backForwordMap = new HashMap<>();

        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
    }

    @GetMapping("/kn_advc_pay_lsn")
    public String list( Model model) {
        // 空一览
        List<Kn02F003LsnFeeAdvcPayBean> list = kn02F003LsnFeeAdvcPayDao.getAdvcFeePayLsnInfo("abc","9999-01");
        model.addAttribute("infoList",list);
        setModel(model);

        return "kn_02f003_advc_pay/kn_02f003_advc_pay_list";
    }

    @GetMapping("/kn_advc_pay_lsn/search")
    public String search(@RequestParam Map<String, Object> queryParams, 
                                       Model model) {
        // 把画面传来的年和月拼接成yyyy-mm的        
        Map<String, Object> params = new HashMap<>();
        String lsnMonth = (String) queryParams.get("selectedmonth");
        int month = Integer.parseInt(lsnMonth); // 将月份转换为整数类型
        lsnMonth = String.format("%02d", month); // 格式化为两位数并添加前导零
        params.put("lsn_month", queryParams.get("selectedyear") + "-" + lsnMonth);
        String stuId = (String) queryParams.get("stuId");
        String yearMonth = queryParams.get("selectedyear") + "-" + lsnMonth;

        // 根据课费编号，取得未支付的课费信息
        List<Kn02F003LsnFeeAdvcPayBean> list = kn02F003LsnFeeAdvcPayDao.getAdvcFeePayLsnInfo(stuId, yearMonth);

        // 回传参数设置（画面检索部的查询参数）
        backForwordMap.putAll(queryParams);
        model.addAttribute("payMap", backForwordMap);

        // 将学生交费信息响应送给前端
        model.addAttribute("infoList", list);
        setModel(model);

        return "kn_02f003_advc_pay/kn_02f003_advc_pay_list";
    }
    
    // 画面基本数据初始化
    private void setModel(Model model) {

        // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
        lsnStuList = kn03D004StuDocDao.getDocedStuList();
        model.addAttribute("lsnfeestuList", lsnStuList);

        // 年度下拉列表框初期化前台页面
        int currentYear = Year.now().getValue();
        model.addAttribute("currentyear", currentYear);
        model.addAttribute("knyearlist", knYear);
        // 月份下拉列表框初期化前台页面
        String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("MM"));
        model.addAttribute("currentmonth", currentMonth);
        model.addAttribute("knmonthlist", knMonth);
    }
}
