package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;

import com.liu.springboot04web.bean.Kn05S002FixedLsnStatusBean;
import com.liu.springboot04web.dao.Kn05S002WeekCalculatorDao;

import java.util.List;


@Controller
public class Kn05S002WeekCalculatorController {
    @Autowired
    private Kn05S002WeekCalculatorDao kn05S002WeekCalculatorDao;
    // 【KNPiano后台维护 学生信息】ボタンをクリック
    @GetMapping("/kn_calculate_Weeks")
    public String list(Model model) {
        List<Kn05S002FixedLsnStatusBean> collection = kn05S002WeekCalculatorDao.getInfoList();
        model.addAttribute("infoList",collection);
        return "kn_calculate_Weeks/kncalculateweeks_list";
    }

    // 执行新的年度周次的新规（一年执行一次：）
    @GetMapping("/kn_calculate_Weeks_new")
    public String calculateWeeksForYear(@RequestParam int year) {
        kn05S002WeekCalculatorDao.insertWeeksForYear(year);
        return "redirect:/kn_calculate_Weeks";
    }

    @DeleteMapping("/kn_calculate_Weeks_deleteAll")
    @ResponseBody
    public ResponseEntity<?> deleteAllWeeks() {
        try {
            
            /*
            // 方法一
            // 如果你想要在响应中包含一些信息，你可以这样修改：这会返回一个状态码为 200 的响应，响应体为文本 "All weeks deleted successfully"。
            return ResponseEntity.ok("All weeks deleted successfully");

            // 如果你想返回 JSON 格式的数据：这会返回一个 JSON 对象 {"message": "All weeks deleted successfully"}。
            Map<String, String> response = new HashMap<>();
            response.put("message", "All weeks deleted successfully");
            return ResponseEntity.ok(response);
            */
            kn05S002WeekCalculatorDao.deleteAll();
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error deleting all weeks");
        }
    }
}