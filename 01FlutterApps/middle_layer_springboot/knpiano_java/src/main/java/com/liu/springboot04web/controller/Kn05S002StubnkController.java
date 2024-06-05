package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn05S002StubnkBean;
import com.liu.springboot04web.dao.Kn05S002StubnkDao;

import java.util.Collection;
@Controller
public class Kn05S002StubnkController{

    @Autowired
    Kn05S002StubnkDao kn05S002StubnkDao;

    // 【学生銀行番号管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_05s002_stubnk_all")
    public String list(Model model) {
        Collection<Kn05S002StubnkBean> collection = kn05S002StubnkDao.getInfoList();
        model.addAttribute("infoList",collection);
        return "kn_05s002_stubnk/kn05s002stubnk_list";
    }

    
    // 【学生銀行番号管理】新規ボタンを押下して、【学生銀行番号管理】新規画面へ遷移すること
    @GetMapping("/kn_05s002_stubnk")
    public String toInfoAdd(Model model) {
        return "kn_05s002_stubnk/kn05s002stubnk_add_update";
    }


    // 【学生銀行番号管理】新規画面にて、【保存】ボタンを押下して、新規情報を保存すること
    @PostMapping("/kn_05s002_stubnk")
    public String excuteInfoAdd(Kn05S002StubnkBean kn05S002StubnkBean) {
        System.out.println("" + kn05S002StubnkBean);
        kn05S002StubnkDao.save(kn05S002StubnkBean);
        return "redirect:/kn_05s002_stubnk_all";
    }


    // 【学生銀行番号管理】編集ボタンを押下して、【学生銀行番号管理】編集画面へ遷移すること
    @GetMapping("/kn_05s002_stubnk/{id}")
    public String toInfoEdit(@PathVariable("id") String id, Model model) {
        Kn05S002StubnkBean kn05S002StubnkBean = kn05S002StubnkDao.getInfoById(id);
        model.addAttribute("selectedinfo", kn05S002StubnkBean);
        return "kn_05s002_stubnk/kn05s002stubnk_add_update";
    }


    // 【学生銀行番号管理】編集画面にて、【保存】ボタンを押下して、変更した情報を保存すること
    @PutMapping("/kn_05s002_stubnk")
    public String excuteInfoEdit(@ModelAttribute Kn05S002StubnkBean kn05S002StubnkBean) {
        kn05S002StubnkDao.save(kn05S002StubnkBean);
        return "redirect:/kn_05s002_stubnk_all";
    }


    // 【学生銀行番号管理】削除ボタンを押下して、当該情報を削除すること
    @DeleteMapping("/kn_05s002_stubnk/{id}")
    public String excuteInfoDelete(@PathVariable("id") String id) {
        kn05S002StubnkDao.delete(id);
        return "redirect:/kn_05s002_stubnk_all";
    }
}
