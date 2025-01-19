package com.liu.springboot04web.controller_mobile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn01L002LsnDao;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;
import com.liu.springboot04web.service.ComboListInfoService;

@RestController
@Service
public class Kn01L002LsnController4Mobile {
    private ComboListInfoService combListInfo;

    @Autowired
    private Kn01L002LsnDao kn01L002LsnDao;

    @Autowired
    private Kn03D004StuDocDao kn03D004StuSubjectDao;

    // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
    public Kn01L002LsnController4Mobile(ComboListInfoService combListInfo) {
        this.combListInfo = combListInfo;
    }

    // 获取所有学生排课信息
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_lsn_all/{year}")
    public ResponseEntity<List<Kn01L002LsnBean>> getInfoStuLsnList(@PathVariable Integer year) {
        // 获取当前正在上课的所有学生的排课信息
        List<Kn01L002LsnBean> collection = kn01L002LsnDao.getInfoList(Integer.toString(year));
        return ResponseEntity.ok(collection);
    }

    // 手机端网页:点击手机日历上的日期，提取指定年月日这一天的课程
    @CrossOrigin(origins = "*") 
    @GetMapping("/mb_kn_lsn_info_by_day/{schedualDate}")
    public ResponseEntity<List<Kn01L002LsnBean>> getInfoListByDay(@PathVariable("schedualDate") String schedualDate) {
        // 获取当前正在上课的所有学生信息
        List<Kn01L002LsnBean> collection = kn01L002LsnDao.getInfoListByDay(schedualDate);
        return ResponseEntity.ok(collection);
    }

    // 课程表一览】画面にて、签到ボタンを押下
    @GetMapping("/mb_kn_lsn_001_lsn_sign/{id}")
    public void lessonSign(@PathVariable("id") String id) {
        // 拿到该课程信息
        Kn01L002LsnBean knLsn001Bean = kn01L002LsnDao.getInfoById(id);
        kn01L002LsnDao.excuteSign(knLsn001Bean);
        // return ResponseEntity.ok("Ok");
    }

    // 课程表一览】画面にて、撤销ボタンを押下
    @GetMapping("/mb_kn_lsn_001_lsn_undo/{id}")
    public void lessonUndo(@PathVariable("id") String id) {

        // 拿到该课程信息
        Kn01L002LsnBean knLsn001Bean = kn01L002LsnDao.getInfoById(id);
        // 撤销签到登记
        kn01L002LsnDao.excuteUndo(knLsn001Bean);
        // return ResponseEntity.ok("Ok");
    }

    // 【课程表一览】画面にて、【编辑】ボタンを押下
    @CrossOrigin(origins = "*") 
    @GetMapping("/mb_kn_lsn_001/{lessonId}")
    public ResponseEntity<Kn01L002LsnBean> getStudentByName(@PathVariable("lessonId") String lessonId) {
        Kn01L002LsnBean kn01L002LsnBean = kn01L002LsnDao.getInfoById(lessonId);
        return ResponseEntity.ok(kn01L002LsnBean);
    }

    // 【学生排课新規、编辑、调课】画面にて、【保存】ボタンを押下
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_lsn_001_save")
    public void excuteInfoAdd(@RequestBody Kn01L002LsnBean knStudoc001Bean) {
        kn01L002LsnDao.save(knStudoc001Bean);
    }

    // 【课程表一覧】取消调课的请求处理
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_lsn_resche_cancel/{lessonId}")
    public ResponseEntity<String> executeInfoRescheCancel(@PathVariable("lessonId") String lessonId) {
        kn01L002LsnDao.reScheduleLsnCancel(lessonId);
        return ResponseEntity.ok("success");
    }

    // 【课程表一覧】削除ボタンを押下
    @CrossOrigin(origins = "*") 
    @DeleteMapping("/mb_kn_lsn_001_delete/{lessonId}")
    public ResponseEntity<String> executeInfoDelete(@PathVariable("lessonId") String lessonId) {
        try {
            kn01L002LsnDao.delete(lessonId);
            return ResponseEntity.ok("success");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)  // 409 Conflict
                    .body("学科编号为【" + lessonId + "】的科目在使用。所以删除不了。");
        }
    }

    // 【课程表一覧】更新备注
    @CrossOrigin(origins = "*")
    @PostMapping("/mb_kn_lsn_001_lsn_memo/{lessonId}")
    public ResponseEntity<Map<String, String>> updateInfoMemo(@PathVariable("lessonId") String lessonId,
            @RequestBody Map<String, String> memoMap) {
        try {
            String memo = memoMap.get("memo");

            // 调用服务层更新备注
            int updatedCnt = kn01L002LsnDao.updateMemo(lessonId, memo);

            if (updatedCnt == 1) {
                Map<String, String> response = new HashMap<>();
                response.put("status", "success");
                response.put("message", "备注更新成功");
                return ResponseEntity.ok(response);
            } else {
                Map<String, String> response = new HashMap<>();
                response.put("status", "error");
                response.put("message", "更新备注失败");
                return ResponseEntity.badRequest().body(response);
            }

        } catch (Exception e) {
            Map<String, String> response = new HashMap<>();
            response.put("status", "error");
            response.put("message", "系统错误：" + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 取得学生的上课时长
    @CrossOrigin(origins = "*")
    @GetMapping("/mb_kn_lsn_duration")
    public ResponseEntity<List<String>> getDurations() {
        // 获取系统定义的排课时长
        final List<String> duration = combListInfo.getDurations();
        return ResponseEntity.ok(duration);
    }

    @PostMapping("/mb_kn_lsn_updatetime")
    public ResponseEntity<String> updateLessonTime(@RequestBody Kn01L002LsnBean requestBody) {

        try {
            // 模拟更新操作，可以替换为实际的服务逻辑
            int isUpdated = kn01L002LsnDao.updateLessonTime(requestBody);

            if (isUpdated > 0) {
                return ResponseEntity.ok("Lesson time updated successfully");
            } else {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body("Failed to update lesson time");
            }
        } catch (Exception e) {
            // 捕获异常并返回错误响应
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error occurred: " + e.getMessage());
        }
    }

    // 手机前端添加课程的排课画面：从学生档案表视图中取得该学生正在上的所有科目信息
    @CrossOrigin(origins = "*") 
    @GetMapping("/mb_kn_latest_subjects/{stuId}")
    public ResponseEntity<List<Kn03D004StuDocBean>> getLatestSubjectListByStuId(@PathVariable("stuId") String stuId) {
        List<Kn03D004StuDocBean> subjectList = kn03D004StuSubjectDao.getLatestSubjectListByStuId(stuId);
        return ResponseEntity.ok(subjectList);
    }

}
