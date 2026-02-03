package com.liu.springboot04web.controller_mobile;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn02F004AdvcLsnFeePayPerLsnBean;
import com.liu.springboot04web.dao.Kn02F004AdvcLsnFeePayPerLsnDao;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;

import java.util.List;

@RestController
@Service
public class Kn02F004AdvcLsnFeePayPerLsnController4Mobile {

    @Autowired
    Kn02F004AdvcLsnFeePayPerLsnDao kn02F004Dao;
    @Autowired
    Kn03D004StuDocDao kn03D004StuDocDao;
    @Autowired
    Kn03D003StubnkDao kn05S002StubnkDao;

    // 取得指定学生的按课时交费科目列表（科目下拉选择器用）
    @GetMapping("/mb_kn_advc_per_lsn_subjects/{stuId}")
    public ResponseEntity<List<Kn02F004AdvcLsnFeePayPerLsnBean>> getSubjectsByStuId(@PathVariable("stuId") String stuId) {
        List<Kn02F004AdvcLsnFeePayPerLsnBean> list = kn02F004Dao.getAdvcFeePayPerLsnSubjectsByStuId(stuId);
        return ResponseEntity.ok(list);
    }

    // 取得按课时交费的在课学生名单列表
    @GetMapping("/mb_kn_advc_per_lsn_cur_stu/{year}")
    public ResponseEntity<List<Kn02F004AdvcLsnFeePayPerLsnBean>> getInfoStuList(@PathVariable("year") String year) {
        List<Kn02F004AdvcLsnFeePayPerLsnBean> list = kn02F004Dao.getAdvcFeePayPerLsnStuInfo();
        return ResponseEntity.ok(list);
    }

    // 点击手机前端画面"推算排课日期"按钮（返回N条记录，含处理模式A/B/C判定）
    @GetMapping("/mb_kn_advc_pay_per_lsn/{stuId}/{yearMonth}")
    public ResponseEntity<List<Kn02F004AdvcLsnFeePayPerLsnBean>> getInfoStuLsnList(
            @PathVariable("stuId") String stuId,
            @PathVariable("yearMonth") String yearMonth,
            @RequestParam("lessonCount") Integer lessonCount,
            @RequestParam("subjectId") String subjectId,
            @RequestParam("subjectSubId") String subjectSubId) {
        List<Kn02F004AdvcLsnFeePayPerLsnBean> list = kn02F004Dao.getAdvcFeePayPerLsnInfo(
                stuId, yearMonth, lessonCount, subjectId, subjectSubId);
        return ResponseEntity.ok(list);
    }

    // 该生指定年度的按课时预支付历史记录
    @GetMapping("/mb_kn_advc_paid_per_lsn_history/{stuId}/{yearMonth}")
    public ResponseEntity<List<Kn02F004AdvcLsnFeePayPerLsnBean>> getAdvcLsnPaidHistory(
            @PathVariable("stuId") String stuId,
            @PathVariable("yearMonth") String yearMonth) {
        List<Kn02F004AdvcLsnFeePayPerLsnBean> advcPaidHistorylist
                    = kn02F004Dao.getAdvcFeePaidPerLsnInfoByCondition(stuId,
                                                                      yearMonth.substring(0,4),
                                                                      null);
        return ResponseEntity.ok(advcPaidHistorylist);
    }

    // 执行按课时预支付处理
    // 业务逻辑：前端发送第一条排课日期+课时数，SP在执行时会重新遍历候选日期并检查课程状态，
    // 根据A/B/C/D模式执行不同操作（D模式自动跳过）。这样设计是为了防止Preview到Execution期间数据状态变化。
    @PostMapping("/mb_kn_advc_pay_per_lsn_execute/{stuId}/{yearMonth}")
    public ResponseEntity<String> executeAdvcLsnFeePayPerLesson(
            @PathVariable("stuId") String stuId,
            @PathVariable("yearMonth") String yearMonth,
            @RequestBody List<Kn02F004AdvcLsnFeePayPerLsnBean> beans) {

        if (beans == null || beans.isEmpty()) {
            return ResponseEntity.ok("没有要处理的数据。");
        }

        String stuName = beans.get(0).getStuName();

        // 调用SP执行按课时预支付（SP内部会重新检查课程状态并判定A/B/C/D模式）
        Kn02F004AdvcLsnFeePayPerLsnBean bean = beans.get(0);
        kn02F004Dao.executeAdvcLsnFeePayPerLesson(bean);

        String successMessage = stuName + "的课费按课时预支付成功。";
        return ResponseEntity.ok(successMessage);
    }
}
