package com.liu.springboot04web.controller_mobile;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn02F002FeeBean;
import com.liu.springboot04web.dao.Kn02F002FeeDao;

@RestController
@Service
public class Kn01L002LsnStatistic4Mobile {

    @Autowired
    private Kn02F002FeeDao kn01L002LsnDao;

    // 手机前端课程进度统计页面的上课完了Tab页（统计指定年度中的每一个已经签到完了的课程（已支付/未支付的课程都算）
    /* 学生上课的课时数的统计为什么用课费金额的模块（Kn02F002F）的原因是，能产生课费的科目都是已经签到完了的科目，
       这对将来维护对业务理解提供方便 */
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_lsn_signed_total/{stuId}/{selectedYear}")
    public ResponseEntity<List<Kn02F002FeeBean>> getInfoStuLsnList(@PathVariable("stuId") String stuId,
                                                                   @PathVariable("selectedYear") Integer year) {
        // 获取当前正在上课的所有学生的排课信息
        List<Kn02F002FeeBean> collection = kn01L002LsnDao.getInfoLsnStatisticList(stuId, Integer.toString(year));
        return ResponseEntity.ok(collection);
    }

}
