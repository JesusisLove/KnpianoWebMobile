package com.liu.springboot04web.controller_mobile;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn02f005FeeMonthlyReportBean;
import com.liu.springboot04web.dao.Kn02f005FeeMonthlyReportDao;

@RestController
@Service
public class Kn02f005FeeReportController4Mobile {

    @Autowired
    Kn02f005FeeMonthlyReportDao kn02f005Dao;

    // @CrossOrigin(origins = "*") 
    @GetMapping("/mb_kn02f005_all/{year}")
    public ResponseEntity<List<Kn02f005FeeMonthlyReportBean>> list(@PathVariable("year") Integer year) {
        List<Kn02f005FeeMonthlyReportBean> list = kn02f005Dao.getInfoList(Integer.toString(year));
        return ResponseEntity.ok(list);
    }


    @GetMapping("/mb_kn02f005_unpaid_details/{yearmonth}")
    public ResponseEntity<List<Kn02f005FeeMonthlyReportBean>>  unPaidDetailslist(@PathVariable("yearmonth") String yearMonth) {
        List<Kn02f005FeeMonthlyReportBean> collection = kn02f005Dao.getUnpaidInfo(yearMonth);
        return ResponseEntity.ok(collection);
    }


}
