package com.liu.springboot04web.controller_mobile;

import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn03D004StuDocBean;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;
import com.liu.springboot04web.service.ComboListInfoService;

import java.util.List;

@RestController
@Service
public class Kn03D004StuDocController4Mobile {

    private ComboListInfoService combListInfo;

    @Autowired
    private Kn03D004StuDocDao knStudoc001Dao;


    // 通过构造器注入方式接收ComboListInfoService的一个实例，获得application.properties里配置的上课时长数组
    public Kn03D004StuDocController4Mobile(ComboListInfoService combListInfo) {
        this.combListInfo = combListInfo;
    }

    // 尚未入档学生信息
    @GetMapping("/mb_kn_undoc_all")
    public ResponseEntity<List<Kn03D004StuDocBean>> getUnDocedList() {
        // 获取当前正在上课的所有学生信息
        List<Kn03D004StuDocBean> collection = knStudoc001Dao.getUnDocedList();
        return ResponseEntity.ok(collection);
    }

    // 已经入档学生信息
    @GetMapping("/mb_kn_studoced_all")
    public ResponseEntity<List<Kn03D004StuDocBean>> getDocedStuList() {
        // 获取当前正在上课的所有学生信息
        List<Kn03D004StuDocBean> collection = knStudoc001Dao.getDocedStuList();
        return ResponseEntity.ok(collection);
    }

    // 手机端网页提取已经入档的学生他本人的历史档案信息 
    @GetMapping("/mb_kn_studoc_detail/{stuId}")
    public ResponseEntity<List<Kn03D004StuDocBean>> getDocedStuDetailList(@PathVariable("stuId") String stuId) {
        // 获取当前正在上课的所有学生信息
        List<Kn03D004StuDocBean> collection = knStudoc001Dao.getDocedstuDetailList(stuId);
        return ResponseEntity.ok(collection);
    }

    // 【档案一览】画面にて、【编辑】ボタンを押下
    @GetMapping("/mb_kn_studoc_001/{stuId}/{subjectId}/{subjectSubId}/{adjustedDate}")
    public ResponseEntity<Kn03D004StuDocBean> getStudentByName(@PathVariable("stuId") String stuId, 
                               @PathVariable("subjectId") String subjectId, 
                               @PathVariable("subjectSubId") String subjectSubId, 
                               @PathVariable ("adjustedDate") 
                               @DateTimeFormat(pattern = "yyyy-MM-dd") // 从html页面传过来的字符串日期转换成可以接受的Date类型日期
                                Date adjustedDate) {

        Kn03D004StuDocBean knStudoc001Bean = knStudoc001Dao.getInfoByKey(stuId, subjectId, subjectSubId, adjustedDate);
        return ResponseEntity.ok(knStudoc001Bean);
    }

    // 【新規编辑】画面にて、【保存】ボタンを押下
    @PostMapping("/mb_kn_studoc_001_save")
    public void excuteInfoAdd(@RequestBody Kn03D004StuDocBean knStudoc001Bean) {
        // 因为是复合主键，只能通过从表里抽出记录来确定是新规操作还是更新操作
        boolean addNewMode = false;

        String stuId = knStudoc001Bean.getStuId();
        String subjectSubId = knStudoc001Bean.getSubjectSubId();
        String subjectId = knStudoc001Bean.getSubjectId();
        Date  adjustedDate = knStudoc001Bean.getAdjustedDate();
        // 确认表里有没有记录，没有就insert，有记录就update
        addNewMode = (knStudoc001Dao.getInfoByKey(stuId, subjectId, subjectSubId, adjustedDate) == null);
        knStudoc001Dao.save(knStudoc001Bean, addNewMode);
    }

    // 【档案一覧】削除ボタンを押下
    @DeleteMapping("/mb_kn_studoc_001_delete/{stuId}/{subjectId}/{subjectSubId}/{adjustedDate}")
    public ResponseEntity<String> executeInfoDelete(@PathVariable("stuId") String stuId, 
                                                    @PathVariable("subjectId") String subjectId, 
                                                    @PathVariable("subjectSubId") String subjectSubId, 
                                                    @PathVariable ("adjustedDate") 
                                                    @DateTimeFormat(pattern = "yyyy-MM-dd") // 从html页面传过来的字符串日期转换成可以接受的Date类型日期
                                                    Date adjustedDate) {
        try {
            knStudoc001Dao.deleteByKeys(stuId, subjectId, subjectSubId,adjustedDate);
            return ResponseEntity.ok("success");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)  // 409 Conflict
                    .body("学科编号为【" + subjectId + "】的科目在使用。所以删除不了。");
        }
    }

    // 取得学生上1节课的分钟时长
    @GetMapping("/mb_kn_duration")
    public ResponseEntity<List<String>> getDurationList() {
        // 获取当前正在上课的所有学生信息
        final List<String> duration = combListInfo.getMinutesPerLsn();
        return ResponseEntity.ok(duration);
    }
}
