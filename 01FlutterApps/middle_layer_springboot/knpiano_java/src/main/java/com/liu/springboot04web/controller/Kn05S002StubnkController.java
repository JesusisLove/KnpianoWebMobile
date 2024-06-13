package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn01B001StuBean;
import com.liu.springboot04web.bean.Kn01B003BnkBean;
import com.liu.springboot04web.bean.Kn05S002StubnkBean;
import com.liu.springboot04web.dao.Kn01B001StuDao;
import com.liu.springboot04web.dao.Kn01B003BnkDao;
import com.liu.springboot04web.dao.Kn05S002StubnkDao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
@Controller
public class Kn05S002StubnkController{

    @Autowired
    Kn05S002StubnkDao Kn05S002StubnkDao;
    @Autowired
    Kn01B001StuDao knStu001Dao;
    @Autowired
    private Kn01B003BnkDao knBnk001Dao;

    // 【学生銀行番号管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_05s002_stubnk_all")
        public String list(Model model) {
        Collection<Kn05S002StubnkBean> collection = Kn05S002StubnkDao.getInfoList();
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
    public String excuteInfoAdd(Kn05S002StubnkBean Kn05S002StubnkBean) {
        Kn05S002StubnkDao.save(Kn05S002StubnkBean);
        return "redirect:/kn_05s002_stubnk_all";
    }

    // // 【学生銀行番号管理】編集ボタンを押下して、【学生銀行番号管理】編集画面へ遷移すること
    // @GetMapping("/kn_05s002_stubnk/{id}")
    // public String toInfoEdit(@PathVariable("id") String id, Model model) {
    //     Kn05S002StubnkBean Kn05S002StubnkBean = Kn05S002StubnkDao.getInfoById(id);
    //     model.addAttribute("selectedinfo", Kn05S002StubnkBean);
    //     return "kn_05s002_stubnk/Kn05S002stubnk_add_update";
    // }

    
    // 【学生銀行番号管理】編集画面にて、【保存】ボタンを押下して、変更した情報を保存すること
    @PutMapping("/kn_05s002_stubnk")
    public String excuteInfoEdit(@ModelAttribute Kn05S002StubnkBean Kn05S002StubnkBean) {
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
        Collection<Kn01B001StuBean> collection = knStu001Dao.getInfoList();
        Map<String, String> map = new HashMap<>();
        for (Kn01B001StuBean bean : collection) {
            map.put(bean.getStuId(), bean.getStuName());
        }
        return map != null ? CommonProcess.sortMapByValues(map) : map;
    }

    // 科目下拉列表框初期化
    private Map<String, String> getBnkCodeValueMap() {
        Collection<Kn01B003BnkBean> collection = knBnk001Dao.getInfoList();

        Map<String, String> map = new HashMap<>();
        for (Kn01B003BnkBean bean : collection) {
            map.put(bean.getBankId(), bean.getBankName());
        }
        return map;
    }
}
