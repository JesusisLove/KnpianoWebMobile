package com.liu.springboot04web.controller_mobile;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn01L002LsnBean;
import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.dao.Kn01L002LsnDao;
import com.liu.springboot04web.dao.Kn02F002FeeDao;

@RestController
@Service
public class Kn01L002LsnStatistic4Mobile {

    @Autowired
    // 获取已经上课完了的课程
    private Kn02F002FeeDao kn02L002LsnScanedDao;

    @Autowired
    // 获取已经排课但是还没有上课课程
    private Kn01L002LsnDao kn01L002LsnUnScanedDao;

    @Autowired
    private Kn01L002LsnDao kn01L002LsnScanedDao;

    // 手机前端课程进度统计页面的【上课完了统计】Tab页（统计指定年度中的每一个已经签到完了的课程（已支付/未支付的课程都算）
    /*
     * 学生上课的课时数的统计为什么用课费金额的模块（Kn02F002F）的原因是，能产生课费的科目都是已经签到完了的科目，
     * 这对将来维护对业务理解提供方便
     */
    // @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_lsn_signed_total/{stuId}/{selectedYear}")
    public ResponseEntity<List<Kn02F002FeeBean>> getInfoStuLsnList(@PathVariable("stuId") String stuId,
            @PathVariable("selectedYear") Integer year) {
        // 获取当前正在上课的所有学生的排课信息
        List<Kn02F002FeeBean> collection = kn02L002LsnScanedDao.getInfoLsnStatisticList(stuId, Integer.toString(year));
        return ResponseEntity.ok(collection);
    }

    // 手机前端课程进度统计页面的【还未上课统计】Tab页（
    // @CrossOrigin(origins = "*")
    @GetMapping("/mb_kn_lsn_unsigned_list/{stuId}/{selectedYear}")
    public ResponseEntity<List<Kn01L002LsnBean>> getUnScanSQDateLsnInfoByYear(@PathVariable("stuId") String stuId,
            @PathVariable("selectedYear") Integer year) {
        // 获取当前已经排课了但是还没有上课的记录
        List<Kn01L002LsnBean> collection = kn01L002LsnUnScanedDao.getUnScanSQDateLsnInfoByYear(stuId,
                Integer.toString(year));
        return ResponseEntity.ok(collection);
    }

    // XXXX的课程进度统计 查询谋学生该年度所有月份已经上完课的详细信息
    // @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_lsn_scaned_lsns/{stuId}/{selectedYear}")
    public ResponseEntity<List<Kn01L002LsnBean>> getScanSQDateLsnInfoByYear(@PathVariable("stuId") String stuId,
            @PathVariable("selectedYear") Integer year) {
        // 获取当前正在上课的所有学生的排课信息
        List<Kn01L002LsnBean> collection = kn01L002LsnScanedDao.getScanSQDateLsnInfoByYear(stuId,
                Integer.toString(year));
        return ResponseEntity.ok(collection);
    }
}
