package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.liu.springboot04web.bean.Kn02F004AdvcLsnFeePayPerLsnBean;
import com.liu.springboot04web.bean.Kn03D003BnkBean;
import com.liu.springboot04web.dao.Kn02F004AdvcLsnFeePayPerLsnDao;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;
import com.liu.springboot04web.mapper.Kn03D003BnkMapper;
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

@Controller
public class Kn02F004AdvcLsnFeePayPerLsnController {
    List<String> knYear = null;
    List<String> knMonth = null;
    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    List<Kn02F004AdvcLsnFeePayPerLsnBean> lsnStuList;
    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap;

    @Autowired
    Kn02F004AdvcLsnFeePayPerLsnDao kn02F004Dao;
    @Autowired
    Kn03D003BnkMapper kn03D003BnkMapper;
    @Autowired
    Kn02F004AdvcLsnFeePayPerLsnDao kn02F004AdvcLsnFeePayPerLsnDao;
    @Autowired
    Kn03D003StubnkDao kn05S002StubnkDao;

    public Kn02F004AdvcLsnFeePayPerLsnController(ComboListInfoService combListInfo) {
        backForwordMap = new HashMap<>();
        this.knYear = DateUtils.getYearList();
        this.knMonth = combListInfo.getMonths();
    }

    @GetMapping("/kn_advc_pay_per_lsn")
    public String list(Model model, @ModelAttribute("successMessage") String successMessage) {
        setModel(model);
        if (!successMessage.isEmpty()) {
            model.addAttribute("successMessage", successMessage);
        }
        return "kn_02f004_advc_pay_per_lsn/kn_02f001_advc_pay_per_lsn";
    }

    // AJAX: 根据学生ID取得该生按课时交费的科目列表（科目下拉选择器用）
    @GetMapping("/kn_advc_pay_per_lsn/subjects")
    @ResponseBody
    public List<Kn02F004AdvcLsnFeePayPerLsnBean> getSubjectsByStuId(@RequestParam("stuId") String stuId) {
        return kn02F004AdvcLsnFeePayPerLsnDao.getAdvcFeePayPerLsnSubjectsByStuId(stuId);
    }

    // 点击Web页面上的【推算排课日期】按钮
    @GetMapping("/kn_advc_pay_per_lsn/search")
    public String search(@RequestParam Map<String, Object> queryParams,
            Model model) {
        String lsnMonth = (String) queryParams.get("selectedmonth");
        String stuId = (String) queryParams.get("stuId");
        String subjectId = (String) queryParams.get("subjectId");
        String subjectSubId = (String) queryParams.get("subjectSubId");
        String lessonCountStr = (String) queryParams.get("lessonCount");
        int lessonCount = 4;
        try { lessonCount = Integer.parseInt(lessonCountStr); } catch (Exception e) { /* default 4 */ }

        if (!validateHasError(model, queryParams, null)) {
            String yearMonth = queryParams.get("selectedyear") + "-" + lsnMonth;

            // 调用SP取得该生指定科目的N条排课日期推算结果（含处理模式A/B/C判定）
            if (subjectId != null && !subjectId.isEmpty() && subjectSubId != null && !subjectSubId.isEmpty()) {
                List<Kn02F004AdvcLsnFeePayPerLsnBean> scheduleList = kn02F004Dao.getAdvcFeePayPerLsnInfo(
                        stuId, yearMonth, lessonCount, subjectId, subjectSubId);

                if (scheduleList != null && !scheduleList.isEmpty()) {
                    model.addAttribute("infoList", scheduleList);
                } else {
                    // SP未返回结果（无固定排课信息）
                    model.addAttribute("infoList", new ArrayList<>());
                    model.addAttribute("noScheduleMessage",
                            "该生该科目无固定排课信息，暂不支持手动输入排课日期（功能开发中）。");
                }
            } else {
                model.addAttribute("infoList", new ArrayList<>());
            }

            // 提取预支付历史情况
            List<Kn02F004AdvcLsnFeePayPerLsnBean> advcPaidHistorylist = kn02F004Dao
                    .getAdvcFeePaidPerLsnInfoByCondition(stuId, yearMonth.substring(0, 4), null);
            model.addAttribute("historyList", advcPaidHistorylist);

            // 根据stuId从银行管理表，取得该学生使用的银行名称
            Map<String, String> stuBankMap = getStuBnkCodeValueMap(stuId);
            model.addAttribute("bankMap", stuBankMap);

            // 取得该生的科目列表（用于页面回显科目下拉选择器）
            List<Kn02F004AdvcLsnFeePayPerLsnBean> subjectList =
                    kn02F004AdvcLsnFeePayPerLsnDao.getAdvcFeePayPerLsnSubjectsByStuId(stuId);
            model.addAttribute("subjectList", subjectList);
        }

        // 回传参数设置
        backForwordMap.putAll(queryParams);
        model.addAttribute("advcPayMap", backForwordMap);

        setModel(model);
        return "kn_02f004_advc_pay_per_lsn/kn_02f001_advc_pay_per_lsn";
    }

    // 点击Web页面上的【课费预支付】按钮
    // 业务逻辑：前端发送第一条排课日期+课时数，SP在执行时会重新遍历候选日期并检查课程状态，
    // 根据A/B/C/D模式执行不同操作（D模式自动跳过）。这样设计是为了防止Preview到Execution期间数据状态变化。
    @PostMapping("/kn_advc_pay_per_lsn_execute")
    public String executeAdvanceLsnFeePayPerLesson(@RequestParam Map<String, Object> queryParams,
            @RequestBody List<Kn02F004AdvcLsnFeePayPerLsnBean> beans,
            RedirectAttributes redirectAttributes,
            Model model) {

        if (beans == null || beans.isEmpty()) {
            redirectAttributes.addFlashAttribute("errorMessage", "没有要处理的数据。");
            return "redirect:/kn_advc_pay_per_lsn";
        }

        String stuName = beans.get(0).getStuName();

        // 调用SP执行按课时预支付（SP内部会重新检查课程状态并判定A/B/C/D模式）
        Kn02F004AdvcLsnFeePayPerLsnBean bean = beans.get(0);
        kn02F004Dao.executeAdvcLsnFeePayPerLesson(bean);

        redirectAttributes.addFlashAttribute("successMessage", stuName + "的课费按课时预支付成功。");
        return "redirect:/kn_advc_pay_per_lsn";
    }

    // 学生银行下拉列表框初期化
    private Map<String, String> getStuBnkCodeValueMap(String stuId) {
        Collection<Kn03D003BnkBean> collection = kn03D003BnkMapper.getInfoList();
        Map<String, String> map = new HashMap<>();
        for (Kn03D003BnkBean bean : collection) {
            map.put(bean.getBankId(), bean.getBankName());
        }
        return map;
    }

    // 画面基本数据初始化
    private void setModel(Model model) {
        lsnStuList = kn02F004AdvcLsnFeePayPerLsnDao.getAdvcFeePayPerLsnStuInfo();
        model.addAttribute("lsnfeestuList", lsnStuList);

        int currentYear = Year.now().getValue();
        model.addAttribute("currentyear", currentYear);
        model.addAttribute("knyearlist", knYear);

        String currentMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("MM"));
        model.addAttribute("currentmonth", currentMonth);
        model.addAttribute("knmonthlist", knMonth);
    }

    private boolean validateHasError(Model model, Map<String, Object> queryParams, Kn02F004AdvcLsnFeePayPerLsnBean bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(queryParams, bean, msgList);
        if (hasError == true) {
            model.addAttribute("selectedinfo", bean);
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedinfo", bean);
        }
        return hasError;
    }

    private boolean inputDataHasError(Map<String, Object> queryParams, Kn02F004AdvcLsnFeePayPerLsnBean bean,
            List<String> msgList) {
        if (queryParams != null) {
            String stuId = (String) queryParams.get("stuId");
            if (stuId.isEmpty()) {
                msgList.add("请选择学生姓名。");
            }
            String subjectId = (String) queryParams.get("subjectId");
            if (subjectId == null || subjectId.isEmpty()) {
                msgList.add("请选择科目。");
            }
        }
        if (bean != null) {
            if (bean.getBankId().isEmpty()) {
                msgList.add("请选择该生使用的银行。");
            }
            if (bean.getSchedualDate() == null) {
                msgList.add("请输入'yyyy-MM-dd hh:mm'格式的日期。");
            }
        }
        return (msgList.size() != 0);
    }
}
