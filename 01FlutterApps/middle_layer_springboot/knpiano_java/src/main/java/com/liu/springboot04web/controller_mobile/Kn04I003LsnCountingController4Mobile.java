package com.liu.springboot04web.controller_mobile;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collection;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn04I003LsnCountingBean;
import com.liu.springboot04web.dao.Kn04I003lsnCountingDao;

@RestController
@Service
public class Kn04I003LsnCountingController4Mobile {

    @Autowired
    Kn04I003lsnCountingDao dao;

    // 手机前端取得目前最新的所有科目
    @GetMapping("/mb_kn_lsn_counting")
    public ResponseEntity<Collection<Kn04I003LsnCountingBean>> getLatestSubjectsList() {
        // 获取当前日期
        LocalDate currentDate = LocalDate.now();
        
        // 获取当前年的01月份，格式为 "2025-01"
        String monthFrom = currentDate.getYear() + "-01";
        
        // 获取当前年的当前月份，格式为 "2025-05"
        String monthTo = currentDate.format(DateTimeFormatter.ofPattern("yyyy-MM"));
        
        // 获取休学学生信息
        Collection<Kn04I003LsnCountingBean> collection = dao.getStuLsnCount(monthFrom, monthTo);
        return ResponseEntity.ok(collection);
    }

    // 手机前端取得目前该科目下所有子科目正在上课的学生信息
    @GetMapping("/mb_kn_lsn_counting_search/{year}/{monthFrom}/{monthTo}")
    public ResponseEntity<Collection<Kn04I003LsnCountingBean>> getSubjectOfStudentsList(@PathVariable("year") String year, 
                                                                                        @PathVariable("monthFrom") String monthFrom,
                                                                                        @PathVariable("monthTo") String monthTo) {
        // 获取休学学生信息
        final Collection<Kn04I003LsnCountingBean> collection = dao.getStuLsnCount(year+"-"+monthFrom, year+"-"+monthTo);
        return ResponseEntity.ok(collection);
    }
}
