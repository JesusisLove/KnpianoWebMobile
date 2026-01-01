package com.liu.springboot04web.controller_mobile;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn01L003ExtraPicesesBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn01L003ExtraPiesesIntoOneDao;
import com.liu.springboot04web.othercommon.DateUtils;
import com.liu.springboot04web.service.ComboListInfoService;

@RestController
@Service
public class Kn01L003ExtraPiesesIntoOneController4Mobile {

    final List<String> knYear;

    // 把要付费的学生信息拿到前台画面，给学生下拉列表框做初期化
    Collection<Kn01L003ExtraPicesesBean> extra2ScheStuList;

    @Autowired
    private Kn01L003ExtraPiesesIntoOneDao kn01L003ExtraPiesesIntoOneDao;

    public Kn01L003ExtraPiesesIntoOneController4Mobile(ComboListInfoService combListInfo) {
        // 初期化年度下拉列表框
        this.knYear = DateUtils.getYearList();
        this.extra2ScheStuList = null;
    }

    // 手机前端：初始化在课学生一览
    @GetMapping("/mb_kn_pieses_into_one_stu/{year}")
    public ResponseEntity<List<Kn03D004StuDocBean>> stuNameList(@PathVariable String year) {
        List<Kn03D004StuDocBean> collection = kn01L003ExtraPiesesIntoOneDao.getStuName4Mobile(year);
        return ResponseEntity.ok(collection);
    }

    // 初期化零碎课拼凑整课页面
    @GetMapping("/mb_kn_pieses_into_one/{year}/{stuId}")
    public ResponseEntity<List<Kn01L003ExtraPicesesBean>> list(@PathVariable String year, @PathVariable String stuId) {
        // 获取当前正在上课的所有学生的排课信息
        List<Kn01L003ExtraPicesesBean> collection = kn01L003ExtraPiesesIntoOneDao.getExtraPiesesLsnList(year, stuId);
        return ResponseEntity.ok(collection);
    }

    // 手机前端：获取零碎加课学生正在上课的科目的最新价格
    @GetMapping("/mb_kn_latest_subject_price/{year}/{stuId}")
    public ResponseEntity<List<Kn03D004StuDocBean>> getLatestPriceList4Mobile(@PathVariable String year, @PathVariable String stuId) {
        // 获取当前正在上课的所有学生的排课信息
        List<Kn03D004StuDocBean> collection = kn01L003ExtraPiesesIntoOneDao.getLatestPrice4Mobile(year, stuId);
        return ResponseEntity.ok(collection);
    }

    // 执行该学生，该年度的零碎课拼凑成整课，并换成计划正课处理
    @PostMapping("/mb_kn_piceses_into_onelsn_sche")
    @Transactional(rollbackFor = Exception.class)
    public ResponseEntity<String> excuteExtraPiceseToSche(@RequestParam String sourceIds,
                                                          @RequestParam String subjectId,
                                                          @RequestParam String subjectSubId,
                                                          @RequestParam String stuId,
                                                          @RequestParam String subjectName,
                                                          @RequestParam String subjectSubName,
                                                          @RequestParam Integer standardDuration, 
                                                          @RequestParam String scanQRDate,
                                                          @RequestParam String memo) {
            // 将sourceIds转换为List<String>
            List<String> oldLessonIdList = Arrays.asList(sourceIds.split(","));
            
            // 验证课程ID列表不为空
            if (oldLessonIdList.isEmpty()) {
                throw new IllegalArgumentException("拼凑来源课程列表不能为空");
            }

            // 日期格式转换
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Date scanQRDateTime;
            try {
                scanQRDateTime = formatter.parse(scanQRDate);
            } catch (ParseException e) {
                throw new IllegalArgumentException("签到日期格式错误，期望格式：yyyy-MM-dd HH:mm，实际：" + scanQRDate, e);
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
            knLsn001Bean.setMemo(memo);
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
        // 重定向回原页面
        return ResponseEntity.ok("sucessd");

    }
}
