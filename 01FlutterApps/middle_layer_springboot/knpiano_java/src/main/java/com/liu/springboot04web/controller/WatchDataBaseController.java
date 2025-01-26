package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.liu.springboot04web.bean.WatchDataBaseBean;
import com.liu.springboot04web.dao.WatchDataBaseDao;
import com.liu.springboot04web.othercommon.CommonProcess;

import java.util.Collection;
import java.util.Map;

@Controller
@Service
public class WatchDataBaseController {

    @Autowired
    private WatchDataBaseDao watchDataBaseDao;

    // 回传参数设置（画面检索部的查询参数）画面检索条件保持变量
    Map<String, Object> backForwordMap; 

    @GetMapping("/kn_watch_db_log")
    public String list(@RequestParam Map<String, Object> queryParams, Model model) {

        model.addAttribute("watchLogMap", queryParams);
        
        /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id
           目的是，这个Map要传递到KnXxx001Mapper.xml哪里做SQL的Where的查询条件 */
        Map<String, Object> conditions = CommonProcess.convertToSnakeCase(queryParams);
        Collection<WatchDataBaseBean> collection = watchDataBaseDao.searcSpExecutionLog(conditions);
        model.addAttribute("infoList", collection);

        return "watch_db_log/watchdblog_list";
    }


    @DeleteMapping("/kn_watch_db_log_deleteAll")
    @ResponseBody
    public ResponseEntity<?> deleteAllWeeks() {
        try {
            watchDataBaseDao.deleteAll();
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error deleting all weeks");
        }
    }

}
