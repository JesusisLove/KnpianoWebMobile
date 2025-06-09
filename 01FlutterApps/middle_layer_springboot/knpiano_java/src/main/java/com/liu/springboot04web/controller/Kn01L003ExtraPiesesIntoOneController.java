package com.liu.springboot04web.controller;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn01L003ExtraPicesesBean;
import com.liu.springboot04web.dao.Kn01L003ExtraPiesesIntoOneDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

@Controller
@Service
public class Kn01L003ExtraPiesesIntoOneController {

    final List<String> knYear;
    final List<String> knMonth;

    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn01L003ExtraPicesesBean> extra2ScheStuList;
    @Autowired
    private Kn01L003ExtraPiesesIntoOneDao kn01L003ExtraPiesesIntoOneDao;


    public Kn01L003ExtraPiesesIntoOneController(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();

        // 初期化月份下拉列表框
        this.knMonth = combListInfo.getMonths();
        this.extra2ScheStuList = null;
    }


    // 页面初期化
    @GetMapping("/kn_pieses_into_one")
    public String list(Model model) {

        // 画面检索条件保持变量初始化前端检索部
        LocalDate currentDate = LocalDate.now();// 获取当前日期

        // 格式化为 yyyy
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy");
        String year = currentDate.format(formatter);
        Collection<Kn01L003ExtraPicesesBean> collection = kn01L003ExtraPiesesIntoOneDao.getExtraPiesesLsnList(year,
                null);
        extra2ScheStuList = collection;
        model.addAttribute("infoList", collection);

        /* 初始化画面检索部 */
        // 把要消化加课的学生信息拿到前台画面，给学生下拉列表框做初期化
        model.addAttribute("extra2ScheStuList", extra2ScheStuList);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(collection);
        model.addAttribute("resultsTabStus", resultsTabStus);

        // 年度下拉列表框初期化前台页面
        model.addAttribute("knyearlist", knYear);

        return "kn_lsn_extra_pieses_into_one/kn_extra_pieces_list";
    }


    // 选择年度切换，初始化该年度下的学生姓名下拉列表框
    @GetMapping("/kn_pieses_into_one/{year}")
    public String list(@PathVariable("year") String year, Model model) {
        List<Kn01L003ExtraPicesesBean> list = kn01L003ExtraPiesesIntoOneDao.getSearchInfo4Stu(year);
        model.addAttribute("extra2ScheStuList", list);

        // 创建 Map 并添加到 Model
        Map<String, String> extra2ScheMap = new HashMap<>();
        extra2ScheMap.put("selectedyear", year);
        model.addAttribute("extra2ScheMap", extra2ScheMap);

        model.addAttribute("knyearlist", knYear);
        model.addAttribute("knmonthlist", knMonth);

        return "kn_lsn_extra_pieses_into_one/kn_extra_pieces_list";
    }


    // 检索该年度，该学生的零碎课数据
    @GetMapping("/kn_pieses_into_one/search")
    public String search(@RequestParam Map<String, Object> queryParams, Model model) {
        String lsnYear = (String) queryParams.get("selectedyear");
        String stuId = (String) queryParams.get("stuId");

        List<Kn01L003ExtraPicesesBean> list = kn01L003ExtraPiesesIntoOneDao.getExtraPiesesLsnList(lsnYear, stuId);
        model.addAttribute("infoList", list);
        // 初始化Web页面学生姓名的下拉列表框
        model.addAttribute("extra2ScheStuList", extra2ScheStuList);

        // 回传参数设置（画面检索部的查询参数）
        Map<String, Object> backForwordMap = new HashMap<>();
        backForwordMap.putAll(queryParams);

        model.addAttribute("extra2ScheMap", backForwordMap);
        model.addAttribute("currentyear", lsnYear);
        model.addAttribute("knyearlist", knYear);

        // 根据Web传过来的年度，取得该年度有碎课的学生姓名，初期化页面的学生姓名下拉列表框
         List<Kn01L003ExtraPicesesBean> pullDownlist = kn01L003ExtraPiesesIntoOneDao.getSearchInfo4Stu(lsnYear);
         // 另外，pullDownlist结果集里还有科目和该科目一节课的课程时长的信息。用于碎课拼整课的计算和判断。
        model.addAttribute("extra2ScheStuList", pullDownlist);

        // 利用resultsTabStus的学生名，在前端页面做Tab
        Map<String, String> resultsTabStus = getResultsTabStus(list);
        model.addAttribute("resultsTabStus", resultsTabStus);

        return "kn_lsn_extra_pieses_into_one/kn_extra_pieces_list";
    }
    

    // 执行该学生，该年度的零碎课拼凑成整课，并换成计划正课处理
    @PostMapping("/kn_piceses_into_onelsn_sche")
    @Transactional(rollbackFor = Exception.class)
    public String executePiecesIntoOne(@RequestParam String sourceIds,
                                        @RequestParam String subjectId,
                                        @RequestParam String subjectSubId,
                                        @RequestParam String stuId,
                                        @RequestParam String subjectName,
                                        @RequestParam String subjectSubName,
                                        @RequestParam Integer standardDuration, 
                                        @RequestParam String scanQRDate,
                                        RedirectAttributes redirectAttributes) {
        
        // 参数验证
        try {
            validateInputParameters(sourceIds, subjectId, subjectSubId, stuId, 
                                subjectName, subjectSubName, standardDuration, scanQRDate);
        } catch (IllegalArgumentException e) {
            redirectAttributes.addFlashAttribute("errorMessage", "参数错误: " + e.getMessage());
            return "redirect:/kn_pieses_into_one";
        }
        
        try {
            // 将sourceIds转换为List<String>
            List<String> oldLessonIdList = Arrays.asList(sourceIds.split(","));
            
            // 验证课程ID列表不为空
            if (oldLessonIdList.isEmpty()) {
                throw new IllegalArgumentException("拼凑来源课程列表不能为空");
            }

            // 日期格式转换
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date scanQRDateTime;
            try {
                scanQRDateTime = formatter.parse(scanQRDate);
            } catch (ParseException e) {
                throw new IllegalArgumentException("签到日期格式错误，期望格式：yyyy-MM-dd HH:mm:ss，实际：" + scanQRDate, e);
            }

            // ① 遍历处理每个零碎课的课程ID，分别在课程表和课费表对它们进行逻辑删除
            for (String oldLessonId : oldLessonIdList) {
                try {
                    // 把零碎课在课程表里的当前记录的del_flg更新成1（表示逻辑删除这些零碎的课程）更新条件是课程编号
                    int deletedLessons = kn01L003ExtraPiesesIntoOneDao.logicalDelLesson(oldLessonId);
                    if (deletedLessons == 0) {
                        throw new RuntimeException("课程ID [" + oldLessonId + "] 在课程表中不存在或已被删除");
                    }

                    // 把零碎课在课费表里的当前记录的del_flg更新成1（表示逻辑删除这些零碎的课费）更新条件是课程编号
                    int deletedFees = kn01L003ExtraPiesesIntoOneDao.logicalDelLsfFee(oldLessonId);
                    if (deletedFees == 0) {
                        throw new RuntimeException("课程ID [" + oldLessonId + "] 在课费表中不存在或已被删除");
                    }
                    
                } catch (Exception e) {
                    throw new RuntimeException("删除零碎课程 [" + oldLessonId + "] 失败: " + e.getMessage(), e);
                }
            }

            // ② 拼凑的完整加课信息作成
            Kn01L002LsnBean knLsn001Bean = new Kn01L002LsnBean();
            knLsn001Bean.setSubjectId(subjectId);
            knLsn001Bean.setSubjectSubId(subjectSubId);
            knLsn001Bean.setStuId(stuId);
            knLsn001Bean.setClassDuration(standardDuration);
            knLsn001Bean.setLessonType(1); // 标记为计划课
            knLsn001Bean.setSchedualDate(scanQRDateTime); // 为了在后面要处理的课费表里能找到计划课的月份，所以用签到日期设置计划课日期
            knLsn001Bean.setScanQrDate(scanQRDateTime);
            
            try {
                // 零碎拼凑的整节加课换正课
                kn01L003ExtraPiesesIntoOneDao.excutePicesesIntoOneAndChangeToSche(knLsn001Bean);
                
                // 验证新课程是否创建成功
                if (knLsn001Bean.getLessonId() == null || knLsn001Bean.getLessonId().trim().isEmpty()) {
                    throw new RuntimeException("新课程创建失败，未获得有效的课程ID");
                }
                
            } catch (Exception e) {
                throw new RuntimeException("创建拼凑完整课程失败: " + e.getMessage(), e);
            }

            // ③ 拼凑完成的整节加课保存到拼凑加课换正课中间表，保存这两者的关联关系
            try {
                Kn01L003ExtraPicesesBean piecesIntoOne = new Kn01L003ExtraPicesesBean();
                piecesIntoOne.setLessonId(knLsn001Bean.getLessonId());

                for (String oldLsnId : oldLessonIdList) {
                    int savedRelations = kn01L003ExtraPiesesIntoOneDao.save(piecesIntoOne.getLessonId(), oldLsnId);
                    if (savedRelations == 0) {
                        throw new RuntimeException("保存课程关联关系失败，新课程ID: " + piecesIntoOne.getLessonId() + ", 原课程ID: " + oldLsnId);
                    }
                }
                
            } catch (Exception e) {
                throw new RuntimeException("保存课程关联关系失败: " + e.getMessage(), e);
            }

            // ④ 把在②保存的新的拼凑出来的1节加课执行签到处理
            try {
                kn01L003ExtraPiesesIntoOneDao.excuteSign(knLsn001Bean);
            } catch (Exception e) {
                throw new RuntimeException("执行签到处理失败: " + e.getMessage(), e);
            }

            // 成功消息
            redirectAttributes.addFlashAttribute("successMessage", 
                "成功将拼凑来源 [" + sourceIds + "] 转换为完整课程！新课程ID: " + knLsn001Bean.getLessonId());
                
        } catch (IllegalArgumentException e) {
            // 参数验证异常
            redirectAttributes.addFlashAttribute("errorMessage", "参数错误: " + e.getMessage());
            return "redirect:/kn_pieses_into_one";
            
        } catch (RuntimeException e) {
            // 业务逻辑异常
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "业务处理失败: " + e.getMessage());
            // 注意：由于使用了@Transactional，这里抛出RuntimeException会自动回滚事务
            throw e; // 重新抛出异常以确保事务回滚
            
        } catch (Exception e) {
            // 其他未预期的异常
            e.printStackTrace();
            redirectAttributes.addFlashAttribute("errorMessage", "系统异常: " + e.getMessage());
            // 注意：由于配置了rollbackFor = Exception.class，这里也会回滚事务
            throw new RuntimeException("处理拼课请求时发生系统异常", e);
        }
        
        // 重定向回原页面
        return "redirect:/kn_pieses_into_one";
    }

    /**
     * 验证输入参数
     */
    private void validateInputParameters(String sourceIds, String subjectId, String subjectSubId, 
                                    String stuId, String subjectName, String subjectSubName,
                                    Integer standardDuration, String scanQRDate) {
        if (sourceIds == null || sourceIds.trim().isEmpty()) {
            throw new IllegalArgumentException("拼凑来源不能为空");
        }
        
        if (subjectId == null || subjectId.trim().isEmpty()) {
            throw new IllegalArgumentException("科目编号不能为空");
        }
        
        if (subjectSubId == null || subjectSubId.trim().isEmpty()) {
            throw new IllegalArgumentException("子科目编号不能为空");
        }
        
        if (stuId == null || stuId.trim().isEmpty()) {
            throw new IllegalArgumentException("学生编号不能为空");
        }
        
        if (subjectName == null || subjectName.trim().isEmpty()) {
            throw new IllegalArgumentException("科目名称不能为空");
        }
        
        if (subjectSubName == null || subjectSubName.trim().isEmpty()) {
            throw new IllegalArgumentException("子科目名称不能为空");
        }
        
        if (standardDuration == null || standardDuration <= 0) {
            throw new IllegalArgumentException("标准课时长必须大于0");
        }
        
        if (scanQRDate == null || scanQRDate.trim().isEmpty()) {
            throw new IllegalArgumentException("签到日期不能为空");
        }
    }

    // 从结果集中去除掉重复的星期，前端页面脚本以此定义tab名
    private Map<String, String> getResultsTabStus(Collection<Kn01L003ExtraPicesesBean> collection) {
        // 首先创建一个用于去重的Map
        Map<String, String> tempMap = new HashMap<>();

        // 填充临时Map
        for (Kn01L003ExtraPicesesBean bean : collection) {
            tempMap.putIfAbsent(bean.getStuId(), bean.getStuName());
        }

        // 按值（学生姓名）排序并收集到新的LinkedHashMap中
        return tempMap.entrySet()
                .stream()
                .sorted(Map.Entry.comparingByValue())
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        Map.Entry::getValue,
                        (oldValue, newValue) -> oldValue, // 处理重复键的情况
                        LinkedHashMap::new // 使用LinkedHashMap保持排序
                ));
    }

}
