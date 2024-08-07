package com.liu.springboot04web.controller;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.liu.springboot04web.bean.Kn03D001StuBean;
import com.liu.springboot04web.dao.Kn03D001StuDao;
import com.liu.springboot04web.dao.Kn05S001LsnFixDao;

@Controller
public class Kn04I001StuWithdrawController {

    @Autowired
    Kn03D001StuDao knStu001Dao;
    @Autowired
    private Kn05S001LsnFixDao knFixLsn001Dao;

    // 【KNPiano后台维护 退学复学管理】ボタンをクリック
    @GetMapping("/kn_stu_mst_all")
    public String list(Model model) {
        List<Kn03D001StuBean> list = knStu001Dao.getInfoList();

        List<Kn03D001StuBean> stuOnLsnList = new ArrayList<>();
        List<Kn03D001StuBean> stuLeaveList = new ArrayList<>();

        for (Kn03D001StuBean stuBean : list) {
            if (stuBean.getDelFlg() == 0) {
                stuOnLsnList.add(stuBean);
            } else if (stuBean.getDelFlg() == 1) {
                stuLeaveList.add(stuBean);
            }
        }
        model.addAttribute("stuOnLsn",stuOnLsnList);
        model.addAttribute("stuLeaveLsn",stuLeaveList);
        return "kn_04i001_stuwithdraw/kn04i001withdraw_list";
    }

    
    // 【明细検索一覧】休学/复学ボタンを押下
    @GetMapping("/kn_stu_leave/{stuId}")
    public String excuteWithdraw(@PathVariable("stuId") String stuId,
                                 @RequestParam(value = "deleteSchedule", required = false) Boolean deleteSchedule) {

        // 执行退学操作
        knStu001Dao.stuWithdraw(stuId);
        // 如果画面CheckBox选中了，也顺便删除固定排课记录
        if (deleteSchedule) {
            knFixLsn001Dao.deleteByKeys(stuId, null, null);
        }

        return "redirect:/kn_stu_mst_all";
    }

    // 【明细検索一覧】复学ボタンを押下
    @GetMapping("/kn_stu_return/{stuId}")
    public String excuteReturn(@PathVariable("stuId") String stuId) {
        knStu001Dao.stuReinstatement(stuId);
        return "redirect:/kn_stu_mst_all";
    }
}
