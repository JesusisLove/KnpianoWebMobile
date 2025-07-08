package com.liu.springboot04web.controller;

import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.liu.springboot04web.bean.Kn02F003AdvcLsnPayListBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn02F003AdvcLsnPayListDao;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;
import com.liu.springboot04web.mapper.Kn03D003BnkMapper;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

 @Controller
public class Kn02F003AdvcLsnPayListController {
    List<String> knYear = null;
    List<String> knMonth = null;
    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    List<Kn03D004StuDocBean> lsnStuList;
    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap;

    @Autowired
    Kn02F003AdvcLsnPayListDao knAdvcLsnPayDao;
    @Autowired
    Kn03D003BnkMapper kn03D003BnkMapper;
    @Autowired
    Kn03D004StuDocDao kn03D004StuDocDao;
    @Autowired
    Kn03D003StubnkDao kn05S002StubnkDao;

    public Kn02F003AdvcLsnPayListController(ComboListInfoService combListInfo) {
        // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
        // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
        backForwordMap = new HashMap<>();

        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
    }


    @GetMapping("/kn_advc_lsn_pay_list")
    public String advcLsnPayHistory(Model model) {

        // 画面初期化基本设定
        setModel(model);

        LocalDate currentDate = LocalDate.now();// 获取当前日期
        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy");
        String year = currentDate.format(formatter);

        // 画面检索条件保持变量初始化前端检索部
        List<Kn02F003AdvcLsnPayListBean> stuNameList = knAdvcLsnPayDao.getAdvcLsnPayStuName(year);
        model.addAttribute("advcPaystuNmList", stuNameList);

        List<Kn02F003AdvcLsnPayListBean> advcPaidHistorylist = knAdvcLsnPayDao.getAdvcLsnPayList(null, year);
        model.addAttribute("historyList", advcPaidHistorylist);

        return "kn_02f003_advc_pay/kn_02f002_advc_pay_list";
    }

        @GetMapping("/kn_advc_lsn_pay_list/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {

        // 画面初期化基本设定
        setModel(model);

        String year = (String) queryParams.get("selectedyear");

        String stuId = (String) queryParams.get("stuId");

        // 画面检索条件保持变量初始化前端检索部
        List<Kn02F003AdvcLsnPayListBean> stuNameList = knAdvcLsnPayDao.getAdvcLsnPayStuName(year);
        model.addAttribute("advcPaystuNmList", stuNameList);

        List<Kn02F003AdvcLsnPayListBean> advcPaidHistorylist = knAdvcLsnPayDao.getAdvcLsnPayList(stuId, year);
        model.addAttribute("historyList", advcPaidHistorylist);

        return "kn_02f003_advc_pay/kn_02f002_advc_pay_list";
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

    }
}
