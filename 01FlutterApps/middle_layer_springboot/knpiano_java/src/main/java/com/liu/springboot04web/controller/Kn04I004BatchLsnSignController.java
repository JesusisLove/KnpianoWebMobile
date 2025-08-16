package com.liu.springboot04web.controller;

import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn04I004BatchLsnSignBean;
import com.liu.springboot04web.dao.Kn01L002LsnDao;
import com.liu.springboot04web.dao.Kn04I004BatchLsnSignDao;

@Controller
public class Kn04I004BatchLsnSignController {
    @Autowired
    private Kn04I004BatchLsnSignDao batchLsnSignDao;

    @Autowired
    private Kn01L002LsnDao knLsn001Dao;

    // 【KNPiano后台维护 批量执行上课签到】
    @GetMapping("/kn_stu_lsn_sign")
    public String list(Model model) {
        List<Kn04I004BatchLsnSignBean> collection = batchLsnSignDao.getWeeksForYear();
        model.addAttribute("infoList", collection);

        return "kn_04i004_batchLsnSignIn/kn_batch_lsn_sign_weeklist";
    }

    // 获取一周的签到课程表信息
    @GetMapping("/kn_stu_one_week_sign/{startWeek}/{endWeek}")
    public String listWeeklyLsnInfo(@PathVariable("startWeek") String startWeek,
                                    @PathVariable("endWeek") String endWeek, Model model) {
        List<Kn04I004BatchLsnSignBean> collection = batchLsnSignDao.getLsnScheOfWeek(startWeek, endWeek);
        model.addAttribute("infoList", collection);

        // 利用resultsTabStus的周一到周日，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collection);
        model.addAttribute("resultsTabStus", resultsTabStus);

        // *** 新增：按日期分组数据 - 这是解决问题的关键 ***
        Map<String, List<Kn04I004BatchLsnSignBean>> lessonsByDate = getLessonsByDate(collection, resultsTabStus);
        model.addAttribute("lessonsByDate", lessonsByDate);

        // 添加调试信息
        System.out.println("=== 调试信息 ===");
        System.out.println("总课程数: " + collection.size());
        System.out.println("Tab数量: " + resultsTabStus.size());
        for (Map.Entry<String, List<Kn04I004BatchLsnSignBean>> entry : lessonsByDate.entrySet()) {
            System.out.println("日期 " + entry.getKey() + " 的课程数: " + entry.getValue().size());
        }
        System.out.println("================");

        return "kn_04i004_batchLsnSignIn/kn_batch_lsn_list";
    }

    // 执行批量签到处理
    @PostMapping("/batch_lesson_signin")
    public String batchLessonSignin(@RequestParam("signinData") String signinData, 
                                Model model) {
        try {
            // 解析JSON数据
            ObjectMapper mapper = new ObjectMapper();
            List<TabSigninData> tabDataList = mapper.readValue(signinData, 
                new TypeReference<List<TabSigninData>>(){});
            
            // 处理签到逻辑
            for (TabSigninData tabData : tabDataList) {
                for (LessonSigninData lesson : tabData.getLessons()) {
                    if (lesson.getSelected() == 1) {
                        // 拿到该课程信息
                        Kn01L002LsnBean knLsn001Bean = knLsn001Dao.getInfoById(lesson.getLessonId());
                        
                        // 执行签到
                        knLsn001Dao.excuteSign(knLsn001Bean);

                    } else if (!lesson.getRemark().isEmpty()) {
                        // 只更新备注
                        knLsn001Dao.updateMemo(lesson.getLessonId(), lesson.getRemark());
                    }
                }
            }
            
            model.addAttribute("message", "批量签到成功！");
            return "redirect:/kn_stu_lsn_sign"; // 返回列表页
                
        } catch (Exception e) {
            model.addAttribute("error", "批量签到失败：" + e.getMessage());
            return "error";
        }
    }

    // *** 新增方法：按日期（从周一到周日）分组课程数据 ***
    private Map<String, List<Kn04I004BatchLsnSignBean>> getLessonsByDate(
            Collection<Kn04I004BatchLsnSignBean> collection, 
            Map<String, String> resultsTabStus) {
        
        Map<String, List<Kn04I004BatchLsnSignBean>> lessonsByDate = new LinkedHashMap<>();
        
        // 为每个日期Tab创建对应的课程列表
        for (String dateKey : resultsTabStus.keySet()) {
            List<Kn04I004BatchLsnSignBean> dailyLessons = collection.stream()
                .filter(lesson -> {
                    // 过滤条件：日期不为空且长度足够，并且日期匹配
                    if (lesson.getSchedualDate() == null) {
                        return false;
                    }
                    if (lesson.getSchedualDate().length() < 10) {
                        return false;
                    }
                    String lessonDate = lesson.getSchedualDate().substring(0, 10);
                    return lessonDate.equals(dateKey);
                })
                .collect(Collectors.toList());
            
            lessonsByDate.put(dateKey, dailyLessons);
            
            // 调试输出每个日期的课程
            System.out.println("日期 " + dateKey + " 匹配的课程:");
            for (Kn04I004BatchLsnSignBean lesson : dailyLessons) {
                System.out.println("  - " + lesson.getLessonId() + ": " + lesson.getStuName() + " (" + lesson.getSchedualDate() + ")");
            }
        }
        
        return lessonsByDate;
    }

    // 从结果集中去除掉重复的日期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn04I004BatchLsnSignBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();

        // 填充临时Map
        for (Kn04I004BatchLsnSignBean bean : collection) {
            String schedualDate = bean.getSchedualDate();
            String scheWeek = bean.getScheWeek();
            
            if (schedualDate != null && schedualDate.length() >= 10) {
                String dateKey = schedualDate.substring(0, 10);
                tempMap.putIfAbsent(dateKey, scheWeek);
            }
        }

        // 按日期排序（周一到周日的正确顺序）
        return tempMap.entrySet()
                .stream()
                .sorted(Map.Entry.comparingByKey()) // 按日期字符串排序，自然就是周一到周日
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (oldValue, newValue) -> oldValue,
                        LinkedHashMap::new
                ));
    }
}

 class TabSigninData {
    private String dateKey;
    private List<LessonSigninData> lessons;
    // getters and setters
    public String getDateKey() {
        return dateKey;
    }
    public void setDateKey(String dateKey) {
        this.dateKey = dateKey;
    }
    public List<LessonSigninData> getLessons() {
        return lessons;
    }
    public void setLessons(List<LessonSigninData> lessons) {
        this.lessons = lessons;
    }

}

 class LessonSigninData {
    private String lessonId;
    private int selected; // 1=选中签到, 0=未选中
    private String remark;
    // getters and setters
    public String getLessonId() {
        return lessonId;
    }
    public void setLessonId(String lessonId) {
        this.lessonId = lessonId;
    }
    public int getSelected() {
        return selected;
    }
    public void setSelected(int selected) {
        this.selected = selected;
    }
    public String getRemark() {
        return remark;
    }
    public void setRemark(String remark) {
        this.remark = remark;
    }
}