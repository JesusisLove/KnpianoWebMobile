package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn03D001StuBean;
import com.liu.springboot04web.bean.Kn03D003BnkBean;
import com.liu.springboot04web.bean.Kn03D003StubnkBean;
import com.liu.springboot04web.dao.Kn03D001StuDao;
import com.liu.springboot04web.dao.Kn03D003BnkDao;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
@Controller
public class Kn03D003StubnkController{

    @Autowired
    Kn03D003StubnkDao Kn05S002StubnkDao;
    @Autowired
    Kn03D001StuDao knStu001Dao;
    @Autowired
    private Kn03D003BnkDao knBnk001Dao;

    // 【学生銀行番号管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_05s002_stubnk_all")
        public String list(Model model) {
        Collection<Kn03D003StubnkBean> collection = Kn05S002StubnkDao.getInfoList();
        model.addAttribute("infoList",collection);
        return "kn_05s002_stubnk/Kn05S002stubnk_list";
    }

    // 【学生銀行番号管理】新規ボタンを押下して、【学生銀行番号管理】新規画面へ遷移すること
    @GetMapping("/kn_05s002_stubnk")
    public String toInfoAdd(Model model) {
        model.addAttribute("stuMap", getStuCodeValueMap());
        model.addAttribute("bnkMap", getBnkCodeValueMap());

        return "kn_05s002_stubnk/Kn05S002stubnk_add_update";
    }

    // 【学生銀行番号管理】新規画面にて、【保存】ボタンを押下して、新規情報を保存すること
    @PostMapping("/kn_05s002_stubnk")
    public String excuteInfoAdd(Model model, Kn03D003StubnkBean Kn05S002StubnkBean) {
        // 画面数据有效性校验
        if (validateHasError(model, Kn05S002StubnkBean)) {
            return "kn_05s002_stubnk/Kn05S002stubnk_add_update";
        }
        Kn05S002StubnkDao.save(Kn05S002StubnkBean);
        return "redirect:/kn_05s002_stubnk_all";
    }

    // 【学生銀行番号管理】削除ボタンを押下して、当該情報を削除すること
    @DeleteMapping("/kn_05s002_stubnk/{id}")
    public String excuteInfoDelete(@PathVariable("id") String id) {
        Kn05S002StubnkDao.delete(id);
        return "redirect:/kn_05s002_stubnk_all";
    }

    // 学生下拉列表框初期化
    private Map<String, String> getStuCodeValueMap() {
        Collection<Kn03D001StuBean> collection = knStu001Dao.getInfoList();
        Map<String, String> map = new HashMap<>();
        for (Kn03D001StuBean bean : collection) {
            map.put(bean.getStuId(), bean.getStuName());
        }
        return map != null ? CommonProcess.sortMapByValues(map) : map;
    }

    // 科目下拉列表框初期化
    private Map<String, String> getBnkCodeValueMap() {
        Collection<Kn03D003BnkBean> collection = knBnk001Dao.getInfoList();

        Map<String, String> map = new HashMap<>();
        for (Kn03D003BnkBean bean : collection) {
            map.put(bean.getBankId(), bean.getBankName());
        }
        return map;
    }

    private boolean validateHasError(Model model, Kn03D003StubnkBean knStuBnk001Bean) {
        boolean hasError = false;
        List<String> msgList = new ArrayList<String>();
        hasError = inputDataHasError(knStuBnk001Bean, msgList);
        if (hasError == true) {
            model.addAttribute("stuMap", getStuCodeValueMap());
            model.addAttribute("bnkMap", getBnkCodeValueMap());
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("selectedinfo", knStuBnk001Bean);
        }
        return hasError;
    }

    private boolean inputDataHasError(Kn03D003StubnkBean knStuBnk001Bean, List<String> msgList) {
        if (knStuBnk001Bean.getStuId()==null || knStuBnk001Bean.getStuId().isEmpty() ) {
            msgList.add("请选择学生姓名");
        }

        if (knStuBnk001Bean.getBankId() == null || knStuBnk001Bean.getBankId().isEmpty()  ) {
            msgList.add("请选择银行名称");
        }
        return (msgList.size() != 0);
    }
}
