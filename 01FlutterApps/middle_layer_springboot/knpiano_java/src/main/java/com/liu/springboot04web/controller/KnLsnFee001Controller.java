package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.KnLsnFee001Bean;
import com.liu.springboot04web.dao.KnLsnFee001Dao;

import java.util.Collection;
@Controller
public class KnLsnFee001Controller{

    @Autowired
    KnLsnFee001Dao knLsnFee001Dao;

    // 【課費情報管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_lsn_fee_001_all")
    public String list(Model model) {
        Collection<KnLsnFee001Bean> collection = knLsnFee001Dao.getInfoList();
        model.addAttribute("infoList",collection);
        return "kn_lsn_fee_001/knlsnfee001_list";
    }

    // 【課費情報管理】新規ボタンを押下して、【課費情報管理】新規画面へ遷移すること
    @GetMapping("/kn_lsn_fee_001")
    public String toInfoAdd(Model model) {
        return "kn_lsn_fee_001/knlsnfee001_add_update";
    }

    // 【課費情報管理】新規画面にて、【保存】ボタンを押下して、新規情報を保存すること
    @PostMapping("/kn_lsn_fee_001")
    public String excuteInfoAdd(KnLsnFee001Bean knLsnFee001Bean) {
        System.out.println("" + knLsnFee001Bean);
        knLsnFee001Dao.save(knLsnFee001Bean);
        return "redirect:/kn_lsn_fee_001_all";
    }

    // 【課費情報管理】編集ボタンを押下して、【課費情報管理】編集画面へ遷移すること
    @GetMapping("/kn_lsn_fee_001/{lsnFeeId}/{lessonId}")
    public String toInfoEdit(@PathVariable("lsnFeeId") String lsnFeeId, 
                             @PathVariable("lessonId") String lessonId,
                             Model model) {
        KnLsnFee001Bean knLsnFee001Bean = knLsnFee001Dao.getInfoById(lsnFeeId, lessonId);
        model.addAttribute("selectedinfo", knLsnFee001Bean);
        return "kn_lsn_fee_001/knlsnfee001_add_update";
    }

    // 【課費情報管理】編集画面にて、【保存】ボタンを押下して、変更した情報を保存すること
    @PutMapping("/kn_lsn_fee_001")
    public String excuteInfoEdit(@ModelAttribute KnLsnFee001Bean knLsnFee001Bean) {
        knLsnFee001Dao.save(knLsnFee001Bean);
        return "redirect:/kn_lsn_fee_001_all";
    }

    // 【課費情報管理】削除ボタンを押下して、当該情報を削除すること
    @DeleteMapping("/kn_lsn_fee_001/{lsnFeeId}/{lessonId}")
    public String excuteInfoDelete(@PathVariable("lsnFeeId") String lsnFeeId, 
                                   @PathVariable("lessonId") String lessonId) {
        knLsnFee001Dao.delete(lsnFeeId, lessonId);
        return "redirect:/kn_lsn_fee_001_all";
    }
}