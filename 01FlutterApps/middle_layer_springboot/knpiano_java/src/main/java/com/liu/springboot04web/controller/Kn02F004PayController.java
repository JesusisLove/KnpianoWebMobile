package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn02F004PayBean;
import com.liu.springboot04web.dao.Kn02F004PayDao;

import java.util.Collection;
@Controller
public class Kn02F004PayController{

    @Autowired
    Kn02F004PayDao knLsnPay001Dao;

    // 【課費支払管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_lsn_pay_001_all")
    public String list(Model model) {
        Collection<Kn02F004PayBean> collection = knLsnPay001Dao.getInfoList();
        model.addAttribute("infoList",collection);
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
        System.out.println("" + knLsnPay001Bean);
        knLsnPay001Dao.save(knLsnPay001Bean);
        return "redirect:/kn_lsn_pay_001_all";
    }

    // 【課費支払管理】編集ボタンを押下して、【課費支払管理】編集画面へ遷移すること
    @GetMapping("/kn_lsn_pay_001/{lsnPayId}/{lsnFeeId}")
        public String toInfoEdit(@PathVariable("lsnPayId") String lsnPayId, 
                                 @PathVariable("lsnFeeId") String lsnFeeId, 
                                  Model model) {
        Kn02F004PayBean knLsnPay001Bean = knLsnPay001Dao.getInfoById(lsnPayId, lsnFeeId);
        model.addAttribute("selectedinfo", knLsnPay001Bean);
        return "kn_lsn_pay_001/knlsnpay001_add_update";
    }

    // 【課費支払管理】編集画面にて、【保存】ボタンを押下して、変更した情報を保存すること
    @PutMapping("/kn_lsn_pay_001")
    public String excuteInfoEdit(@ModelAttribute Kn02F004PayBean knLsnPay001Bean) {
        knLsnPay001Dao.save(knLsnPay001Bean);
        return "redirect:/kn_lsn_pay_001_all";
    }

    // 【課費支払管理】削除ボタンを押下して、当該情報を削除すること
    @DeleteMapping("/kn_lsn_pay_001/{lsnPayId}/{lsnFeeId}")
    public String excuteInfoDelete(@PathVariable("lsnPayId") String lsnPayId, 
                                   @PathVariable("lsnFeeId") String lsnFeeId) {
        knLsnPay001Dao.delete(lsnPayId, lsnFeeId);
        return "redirect:/kn_lsn_pay_001_all";
    }
}
