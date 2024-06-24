package com.liu.springboot04web.controller_mobile;

import java.util.Collection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import com.liu.springboot04web.bean.Kn03D003StubnkBean;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;

@Controller
public class Kn03D003StubnkController4Mobile {
    @Autowired
    Kn03D003StubnkDao Kn03D003StubnkDao;

    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_03d003_students_by_bankid/{bankId}")
    public ResponseEntity<Collection<Kn03D003StubnkBean>> getStuBankList(@PathVariable("bankId") String bankId) {
        // 获取目前所有科目信息显示在画面一览上
        Collection<Kn03D003StubnkBean> collection = Kn03D003StubnkDao.getInfoByBnkId(bankId);
        return ResponseEntity.ok(collection);
    }

    // 【新規/编辑】画面にて、【保存】ボタンを押下
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_03d003_bank_stu")
    public ResponseEntity<String>  excuteInfoAdd(@RequestBody Kn03D003StubnkBean knSub001Bean) {
        Kn03D003StubnkDao.save(knSub001Bean);
        return ResponseEntity.ok("success");
    }

    // 【学科一覧】削除ボタンを押下
    @CrossOrigin(origins = "*") 
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