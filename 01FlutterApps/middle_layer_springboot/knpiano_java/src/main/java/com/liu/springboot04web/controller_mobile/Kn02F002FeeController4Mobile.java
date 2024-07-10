package com.liu.springboot04web.controller_mobile;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn02F004FeePaid4MobileBean;
import com.liu.springboot04web.bean.Kn02F004UnpaidBean;
import com.liu.springboot04web.dao.Kn02F002FeeDao;
import com.liu.springboot04web.dao.Kn02F004PayDao;
import com.liu.springboot04web.dao.Kn02F004UnpaidDao;

@RestController
@Service
public class Kn02F002FeeController4Mobile {

    @Autowired
    Kn02F002FeeDao knLsnFee001Dao;

    @Autowired
    Kn02F004UnpaidDao knLsnUnPaid001Dao;

    @Autowired
    Kn02F004PayDao knLsnPay001Dao;

    // 取得该生当前年度的课费详细信息
    @CrossOrigin(origins = "*") 
    @GetMapping("/mb_kn_lsn_fee_by_year/{stuId}/{selectedYear}")
    /*  因为手机前端的处理根后台维护处理方式不同，手机前端是把Kn01002LsnBean，Kn02F004UnpaidBean，Kn02F004PayBean的项目都放在一起处理了
     *  所以，Kn02F004FeePaid4MobileBean就是上面三个Bean项目的并集。
    */
    public ResponseEntity<List<Kn02F004FeePaid4MobileBean>> getStuFeeDetaillist(@PathVariable("stuId") String stuId,
                                                                     @PathVariable("selectedYear") Integer year) {
        List<Kn02F004FeePaid4MobileBean> list = knLsnFee001Dao.getStuFeeDetaillist(stuId, Integer.toString(year));
        return ResponseEntity.ok(list);
    }

    // 在学生的课费账单画面点击【学费入账】按钮处理
    @CrossOrigin(origins = "*") 
    @PostMapping("/mb_kn_lsn_pay_save")
    public ResponseEntity<String> excuteLsnPay(@RequestBody List<Kn02F004UnpaidBean> kn02F004UnpaidList) {
        for (Kn02F004UnpaidBean kn02f002FeeBean : kn02F004UnpaidList) {
            knLsnUnPaid001Dao.excuteLsnPay(kn02f002FeeBean);
        }
        return ResponseEntity.ok("Ok");
    }

    // 【課費精算管理】撤销ボタンを押下して、当該情報を引き戻すこと
    @DeleteMapping("/mb_kn_lsn_pay_undo/{lsnPayId}/{lsnFeeId}")
    public ResponseEntity<String> undoLsnPay(@PathVariable("lsnPayId") String lsnPayId, @PathVariable("lsnFeeId") String lsnFeeId) {
        knLsnPay001Dao.excuteUndoLsnPay(lsnPayId, lsnFeeId);
        return ResponseEntity.ok("Ok");
    }
}
