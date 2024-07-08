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
public class Kn02F002FeeController4Mobile {

    @Autowired
    Kn02F002FeeDao knLsnFee001Dao;

    // 取得该生当前年度的课费详细信息
    @CrossOrigin(origins = "*") 
    @GetMapping("/mb_kn_lsn_fee_by_year/{stuId}/{selectedYear}")
    public ResponseEntity<List<Kn02F002FeeBean>> getStuFeeDetaillist(@PathVariable("stuId") String stuId,
                                                                     @PathVariable("selectedYear") Integer year) {
        List<Kn02F002FeeBean> list = knLsnFee001Dao.getStuFeeDetaillist(stuId, Integer.toString(year));
        return ResponseEntity.ok(list);
    }
}
