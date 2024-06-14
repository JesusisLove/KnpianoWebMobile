package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.dao.Kn02F002FeeDao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
@Controller
public class Kn02F002FeeController{

    @Autowired
    Kn02F002FeeDao knLsnFee001Dao;

    // 【課費情報管理】ボタンをクリックして，全ての情報を表示すること
    @GetMapping("/kn_lsn_fee_001_all")
    public String list(Model model) {
        Collection<Kn02F002FeeBean> collection = knLsnFee001Dao.getInfoList();
        model.addAttribute("infoList",collection);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collection);
        model.addAttribute("resultsTabStus", resultsTabStus);

        return "kn_lsn_fee_001/knlsnfee001_list";
    }

    // 【検索一覧】検索ボタンを押下
    @GetMapping("/kn_lsn_fee_001/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);
        model.addAttribute("stuLsnFeeMap", backForwordMap);

        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如: stuId改成stu_id
           目的是，这个Map要传递到KnStudoc001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);

        // 将queryParams传递给Service层或Mapper接口
        Collection<Kn02F002FeeBean> searchResults = knLsnFee001Dao.searchLsnFee(conditions);
        model.addAttribute("infoList", searchResults);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(searchResults);
        model.addAttribute("resultsTabStus", resultsTabStus);
        
        return "kn_lsn_fee_001/knlsnfee001_list"; // 返回只包含搜索结果表格部分的Thymeleaf模板
    }

    // 【課費情報管理】新規ボタンを押下して、【課費情報管理】新規画面へ遷移すること
    @GetMapping("/kn_lsn_fee_001")
    public String toInfoAdd(Model model) {
        return "kn_lsn_fee_001/knlsnfee001_add_update";
    }

    // 【課費情報管理】新規画面にて、【保存】ボタンを押下して、新規情報を保存すること
    @PostMapping("/kn_lsn_fee_001")
    public String excuteInfoAdd(Kn02F002FeeBean knLsnFee001Bean) {
        System.out.println("" + knLsnFee001Bean);
        knLsnFee001Dao.save(knLsnFee001Bean);
        return "redirect:/kn_lsn_fee_001_all";
    }

    // 【課費情報管理】編集ボタンを押下して、【課費情報管理】編集画面へ遷移すること
    @GetMapping("/kn_lsn_fee_001/{lsnFeeId}/{lessonId}")
    public String toInfoEdit(@PathVariable("lsnFeeId") String lsnFeeId, 
                             @PathVariable("lessonId") String lessonId,
                             Model model) {
        Kn02F002FeeBean knLsnFee001Bean = knLsnFee001Dao.getInfoById(lsnFeeId, lessonId);
        model.addAttribute("selectedinfo", knLsnFee001Bean);
        return "kn_lsn_fee_001/knlsnfee001_add_update";
    }

    // 【課費情報管理】編集画面にて、【保存】ボタンを押下して、変更した情報を保存すること
    @PutMapping("/kn_lsn_fee_001")
    public String excuteInfoEdit(@ModelAttribute Kn02F002FeeBean knLsnFee001Bean) {
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

    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn02F002FeeBean> collection) {

        Map<String, String> activeStudentsMap = new HashMap<>();
        Set<String> seenStuIds = new HashSet<>();

        for (Kn02F002FeeBean bean : collection) {
            String stuId = bean.getStuId();
            if (!seenStuIds.contains(stuId)) {
                activeStudentsMap.put(stuId, bean.getStuName());
                seenStuIds.add(stuId);
            }
        }

        return activeStudentsMap;
    }
}