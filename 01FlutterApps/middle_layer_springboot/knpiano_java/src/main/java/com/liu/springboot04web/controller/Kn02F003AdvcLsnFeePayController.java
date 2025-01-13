package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.liu.springboot04web.bean.Kn02F003AdvcLsnFeePayBean;
import com.liu.springboot04web.bean.Kn03D003StubnkBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn02F003AdvcLsnFeePayDao;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Map;
import java.time.LocalDate;
import java.time.Year;
import java.time.format.DateTimeFormatter;
import java.text.SimpleDateFormat;

@Controller
public class Kn02F003AdvcLsnFeePayController {
    List<String> knYear = null; 
    List<String> knMonth = null;
    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    List<Kn03D004StuDocBean> lsnStuList;
    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap;

    @Autowired
    Kn02F003AdvcLsnFeePayDao kn02F003LsnFeeAdvcPayDao;
    @Autowired
    Kn03D004StuDocDao kn03D004StuDocDao;
    @Autowired
    Kn03D003StubnkDao kn05S002StubnkDao;

    public Kn02F003AdvcLsnFeePayController(ComboListInfoService combListInfo) {
        // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
        // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
        backForwordMap = new HashMap<>();

        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
    }

    @GetMapping("/kn_advc_pay_lsn")
    public String list(Model model, @ModelAttribute("successMessage") String successMessage) {

        // 画面初期化基本设定
        setModel(model);
        // System.out.println("Received successMessage: " + successMessage); 
        if (!successMessage.isEmpty()) {
            model.addAttribute("successMessage", successMessage);
        }

        return "kn_02f003_advc_pay/kn_02f003_advc_pay_list";
    }

    // 点击Web页面上的【推算排课日期】按钮
    @GetMapping("/kn_advc_pay_lsn/search")
    public String search(@RequestParam Map<String, Object> queryParams, 
                                       Model model) {
        // 把画面传来的年和月拼接成yyyy-mm的形式        
        Map<String, Object> params = new HashMap<>();
        String lsnMonth = (String) queryParams.get("selectedmonth");
        params.put("lsn_month", queryParams.get("selectedyear") + "-" + lsnMonth);
        String stuId = (String) queryParams.get("stuId");

        if (!validateHasError(model,queryParams,null)) {
            String yearMonth = queryParams.get("selectedyear") + "-" + lsnMonth;
            // 将学生交费信息响应送给前端
            List<Kn02F003AdvcLsnFeePayBean> list = kn02F003LsnFeeAdvcPayDao.getAdvcFeePayLsnInfo(stuId, yearMonth);
            model.addAttribute("infoList", list);

            // 提取#{引数.生徒番号}、#{引数.基準月}的预支付历史情况
            List<Kn02F003AdvcLsnFeePayBean> advcPaidHistorylist = kn02F003LsnFeeAdvcPayDao.getAdvcFeePaidInfoByCondition(stuId, yearMonth.substring(0,4) ,null);
            model.addAttribute("historyList", advcPaidHistorylist);

            // 根据stuId从银行管理表，取得该学生使用的银行名称（复数个银行可能）
            Map<String, String> stuBankMap = getStuBnkCodeValueMap(stuId);
            model.addAttribute("bankMap", stuBankMap);
        }

        // 回传参数设置（画面检索部的查询参数）
        backForwordMap.putAll(queryParams);
        model.addAttribute("advcPayMap", backForwordMap);

        // 画面初期化基本设定
        setModel(model);

        return "kn_02f003_advc_pay/kn_02f003_advc_pay_list";
    }
    
    //点击Web页面上的【课费预支付】按钮
    @PostMapping("/kn_advc_pay_lsn_execute")
    public String executeAdvanceLsnFeePay(@RequestParam Map<String, Object> queryParams, 
                                          @RequestBody List<Kn02F003AdvcLsnFeePayBean> beans,
                                          RedirectAttributes redirectAttributes,
                                          Model model) {

        // 执行之前先做check：是否同一个月的课费预支付在重复执行（查看课费预支付表 t_info_lsn_fee_advc_pay）
        String stuName = beans.get(0).getStuName();
        String yearMonth = new SimpleDateFormat("yyyy-MM").format(beans.get(0).getSchedualDate());

        // 对科目的学费进行预支付处理（For循环：如果前端页面选中了多个科目，就对各个科目分别进行预支付处理）
        for (Kn02F003AdvcLsnFeePayBean bean : beans) {
            if (!hasPaid(bean)) {
                // 对每个bean进行处理
                kn02F003LsnFeeAdvcPayDao.executeAdvcLsnFeePay(bean);






                
            } else {
                // 如果有重复，则返回更新不可消息
                redirectAttributes.addFlashAttribute("errorMessage", stuName + "的" + yearMonth + "的预支付课费已经支付了，不能再重复支付。");
                return "redirect:/kn_advc_pay_lsn";
            }
        }
        
        // 添加成功消息
        redirectAttributes.addFlashAttribute("successMessage", stuName + "的课费成功预支付。");
        return "redirect:/kn_advc_pay_lsn";
    }

    // 判断当前要预支付的课是否在对象月里已经预支付了（避免重复预支付）
    private boolean hasPaid (Kn02F003AdvcLsnFeePayBean bean) {

        String stuId = bean.getStuId();
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
        String formattedDate = formatter.format(bean.getSchedualDate());
        String yearMonth = formattedDate.substring(0,7);

        List<Kn02F003AdvcLsnFeePayBean> advcPaidList = kn02F003LsnFeeAdvcPayDao.getAdvcFeePaidInfoByCondition(stuId, null, yearMonth);
        // true:表示已经预支付了
        return (advcPaidList.size() > 0);
    }

    // 学生银行下拉列表框初期化
    private Map<String, String> getStuBnkCodeValueMap(String stuId) {
        Collection<Kn03D003StubnkBean> collection = kn05S002StubnkDao.getInfoById(stuId);

        Map<String, String> map = new HashMap<>();
        for (Kn03D003StubnkBean bean : collection) {
            map.put(bean.getBankId(), bean.getBankName());
        }
        return map;
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

    private boolean validateHasError(Model model, Map<String, Object> queryParams, Kn02F003AdvcLsnFeePayBean bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(queryParams, bean, msgList);
        if (hasError == true) {
            // 将学生交费信息响应送给前端
            model.addAttribute("selectedinfo", bean);

            // 将错误消息显示在画面上
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedinfo", bean);
        }

        return hasError;
    }

    private boolean inputDataHasError(Map<String, Object> queryParams,Kn02F003AdvcLsnFeePayBean bean, List<String> msgList) {
        
        if (queryParams != null) {
            String stuId = (String)queryParams.get("stuId");
            if (stuId.isEmpty()) {
                msgList.add("请选择学生姓名。");

            }
        }

        if(bean != null) {

            if(bean.getBankId().isEmpty()) {
                msgList.add("请选择该生使用的银行。");

            }

            if (bean.getSchedualDate()==null) {
                msgList.add("请输入‘yyyy-MM-dd hh:mm’格式的日期。");
            }
        }
        return (msgList.size() != 0);
    }
}
