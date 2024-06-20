package com.liu.springboot04web.controller;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.liu.springboot04web.bean.Kn01B002SubBean;
import com.liu.springboot04web.bean.Kn05S003SubjectEdabnBean;
import com.liu.springboot04web.dao.Kn01B002SubDao;
import com.liu.springboot04web.dao.Kn05S003SubjectEdabnDao;
import com.liu.springboot04web.othercommon.CommonProcess;

@Controller
public class Kn05S003SubjectEdabnController {

    @Autowired
    Kn05S003SubjectEdabnDao kn05S003SubjectEdabnDao;
    @Autowired
    Kn01B002SubDao kn01B002SubDao;

    // 【科目枝番管理設定】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_05s003_subject_edabn_all")
    public String list(Model model) {
        Collection<Kn05S003SubjectEdabnBean> collection = kn05S003SubjectEdabnDao.getInfoList();
        model.addAttribute("infoList",collection);
        return "kn_05s003_subject_edabn/kn05s003subjectedabn_list";
    }


    // 【明细検索一覧】検索ボタンを押下
    @GetMapping("/kn_05s003_subject_edabn/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("edaSubMap", backForwordMap);

        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<Kn05S003SubjectEdabnBean> searchResults = kn05S003SubjectEdabnDao.searchEdaSubject(conditions);
        model.addAttribute("infoList", searchResults);
        return "kn_05s003_subject_edabn/kn05s003subjectedabn_list";// 返回只包含搜索结果表格部分的Thymeleaf模板
    }


    // 【科目枝番管理設定】新規ボタンを押下して、【科目枝番管理設定】新規画面へ遷移すること
    @GetMapping("/kn_05s003_subject_edabn")
    public String toInfoAdd(Model model) {
        model.addAttribute("subMap",getSubCodeValueMap());
        return "kn_05s003_subject_edabn/kn05s003subjectedabn_add_update";
    }


    // 【科目枝番管理設定】新規画面にて、【保存】ボタンを押下して、新規情報を保存すること
    @PostMapping("/kn_05s003_subject_edabn")
    public String excuteInfoAdd(Model model, Kn05S003SubjectEdabnBean kn05S003SubjectEdabnBean) {
        // 画面数据有效性校验
        if (validate(model, kn05S003SubjectEdabnBean)) {
            return "kn_05s003_subject_edabn/kn05s003subjectedabn_add_update";
        }
        kn05S003SubjectEdabnDao.save(kn05S003SubjectEdabnBean);
        return "redirect:/kn_05s003_subject_edabn_all";
    }


    // 【科目枝番管理設定】編集ボタンを押下して、【科目枝番管理設定】編集画面へ遷移すること
    @GetMapping("/kn_05s003_subject_edabn/{subId}/{edabanId}")
    public String toInfoEdit(@PathVariable("subId") String subId, 
                             @PathVariable("edabanId") String edabanId,  Model model) {
        Kn05S003SubjectEdabnBean kn05S003SubjectEdabnBean = kn05S003SubjectEdabnDao.getInfoById(subId, edabanId);
        model.addAttribute("selectedinfo", kn05S003SubjectEdabnBean);
        return "kn_05s003_subject_edabn/kn05s003subjectedabn_add_update";
    }


    // 【科目枝番管理設定】編集画面にて、【保存】ボタンを押下して、変更した情報を保存すること
    @PutMapping("/kn_05s003_subject_edabn")
    public String excuteInfoEdit(Model model, @ModelAttribute Kn05S003SubjectEdabnBean kn05S003SubjectEdabnBean) {
        // 画面数据有效性校验
        if (validate(model, kn05S003SubjectEdabnBean)) {
            return "kn_05s003_subject_edabn/kn05s003subjectedabn_add_update";
        }
        kn05S003SubjectEdabnDao.save(kn05S003SubjectEdabnBean);
        return "redirect:/kn_05s003_subject_edabn_all";
    }


    // 【科目枝番管理設定】削除ボタンを押下して、当該情報を削除すること
    @DeleteMapping("/kn_05s003_subject_edabn/{subId}/{edabanId}")
    public String excuteInfoDelete(@PathVariable("subId") String subId,
                                   @PathVariable("edabanId") String edabanId) {
        kn05S003SubjectEdabnDao.delete(subId, edabanId);
        return "redirect:/kn_05s003_subject_edabn_all";
    }

        // 科目下拉列表框初期化
    private Map<String, Object> getSubCodeValueMap() {
        Collection<Kn01B002SubBean> collection = kn01B002SubDao.getInfoList();

        Map<String, Object> map = new HashMap<>();
        for (Kn01B002SubBean bean : collection) {
            map.put(bean.getSubjectId(), bean);
        }
        return map;
    }

    private boolean validate(Model model, Kn05S003SubjectEdabnBean kn05S003SubjectEdabnBean) {
        boolean bln = false;
        List<String> msgList = new ArrayList<String>();
        bln = inputDataHasError(kn05S003SubjectEdabnBean, msgList);
        if (bln == true) {
            model.addAttribute("errorMessageList", msgList);
            model.addAttribute("subMap",getSubCodeValueMap());
            model.addAttribute("selectedinfo", kn05S003SubjectEdabnBean);
        }
        return bln;
    }

    private boolean inputDataHasError(Kn05S003SubjectEdabnBean kn05S003SubjectEdabnBean, List<String> msgList) {
        if (kn05S003SubjectEdabnBean.getSubjectId().isEmpty() ) {
            msgList.add("请选择科目名称");
        }
        if (kn05S003SubjectEdabnBean.getSubjectSubName().isEmpty() ) {
            msgList.add("请输入枝番名称");
        }
        if (kn05S003SubjectEdabnBean.getSubjectPrice()<= 0) {
            msgList.add("请输入该科目的价格");
        }
        return (msgList.size() != 0);
    }
}