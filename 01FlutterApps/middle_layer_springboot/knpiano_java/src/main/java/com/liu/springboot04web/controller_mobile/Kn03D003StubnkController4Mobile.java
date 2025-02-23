package com.liu.springboot04web.controller_mobile;

import java.util.Collection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import com.liu.springboot04web.bean.Kn03D003BnkBean;
import com.liu.springboot04web.bean.Kn03D003StubnkBean;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;
import com.liu.springboot04web.mapper.Kn03D003BnkMapper;

@Controller
public class Kn03D003StubnkController4Mobile {
    @Autowired
    Kn03D003StubnkDao Kn03D003StubnkDao;
    @Autowired
    Kn03D003BnkMapper kn03D003BnkMapper;

    @GetMapping("/mb_kn_03d003_students_by_bankid/{bankId}")
    public ResponseEntity<Collection<Kn03D003StubnkBean>> getStuBankList(@PathVariable("bankId") String bankId) {
        // 获取目前所有科目信息显示在画面一览上
        Collection<Kn03D003StubnkBean> collection = Kn03D003StubnkDao.getInfoByBnkId(bankId);
        return ResponseEntity.ok(collection);
    }

    // 学费记账的画面初期表示里，用到该生名下ta的银行名称
    @GetMapping("/mb_kn_03d003_banks_by_stuid/{stuId}")
    public ResponseEntity<Collection<Kn03D003BnkBean>> getStuBankList2(@PathVariable("stuId") String stuId) {
        /* ↓↓↓↓↓↓↓↓　这块的业务逻辑目前是不需要的，这里取的不是学生的银行，而是老师的银行信息 ↓↓↓↓↓↓↓　*/
        // // 获取该学生的银行信息
        // Collection<Kn03D003StubnkBean> collection = Kn03D003StubnkDao.getInfoById(stuId);
        /* ↑↑↑↑↑↑↑↑　这块的业务逻辑目前是不需要的，这里取的不是学生的银行，而是老师的银行信息 ↑↑↑↑↑↑↑↑　*/

        Collection<Kn03D003BnkBean> collection = kn03D003BnkMapper.getInfoList();
        return ResponseEntity.ok(collection);
    }

    // 【新規/编辑】画面にて、【保存】ボタンを押下
    @PostMapping("/mb_kn_03d003_bank_stu")
    public ResponseEntity<String>  excuteInfoAdd(@RequestBody Kn03D003StubnkBean knSub001Bean) {
        Kn03D003StubnkDao.save(knSub001Bean);
        return ResponseEntity.ok("success");
    }

    // 【学科一覧】削除ボタンを押下
    @DeleteMapping("/mb_kn_03d003_bank_stu/{stuId}/{bankId}")
    public ResponseEntity<String> executeInfoDelete(@PathVariable("stuId") String stuId,
                                                    @PathVariable("bankId") String bankId) {
        try {
            Kn03D003StubnkDao.delete(stuId, bankId);
            return ResponseEntity.ok("success");
        } catch (DataIntegrityViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)  // 409 Conflict
                    .body("学生银行编号为【" + bankId + "】的银行有学生在用。所以删除不了。");
        }
    }
}