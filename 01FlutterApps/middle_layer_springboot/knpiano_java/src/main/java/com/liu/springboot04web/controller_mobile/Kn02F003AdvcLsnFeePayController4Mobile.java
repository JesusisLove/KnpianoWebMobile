package com.liu.springboot04web.controller_mobile;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.liu.springboot04web.bean.Kn02F003AdvcLsnFeePayBean;
import com.liu.springboot04web.dao.Kn02F003AdvcLsnFeePayDao;
import com.liu.springboot04web.dao.Kn03D003StubnkDao;
import com.liu.springboot04web.dao.Kn03D004StuDocDao;

import java.util.List;


@RestController
@Service
public class Kn02F003AdvcLsnFeePayController4Mobile {


@   Autowired
    Kn02F003AdvcLsnFeePayDao kn02F003LsnFeeAdvcPayDao;
    @Autowired
    Kn03D004StuDocDao kn03D004StuDocDao;
    @Autowired
    Kn03D003StubnkDao kn05S002StubnkDao;

    //取得该生预支付的科目信息
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_advc_pay_lsn/{stuId}/{yearMonth}")
    public ResponseEntity<List<Kn02F003AdvcLsnFeePayBean>> getInfoStuLsnList(@PathVariable("stuId")     String stuId,
                                                                             @PathVariable("yearMonth") String yearMonth) {
        // 将学生交费信息响应送给前端
        List<Kn02F003AdvcLsnFeePayBean> list = kn02F003LsnFeeAdvcPayDao.getAdvcFeePayLsnInfo(stuId, yearMonth);

        return ResponseEntity.ok(list);
    }

    // 该生指定年度的预支付历史记录
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @GetMapping("/mb_kn_advc_paid_history/{stuId}/{yearMonth}")
    public ResponseEntity<List<Kn02F003AdvcLsnFeePayBean>> getAdvcLsnPaidHistory(@PathVariable("stuId")     String stuId,
                                                                                 @PathVariable("yearMonth") String yearMonth) {
        // 提取该生当前月份的预支付历史情况
        List<Kn02F003AdvcLsnFeePayBean> advcPaidHistorylist 
                    = kn02F003LsnFeeAdvcPayDao.getAdvcFeePaidInfoByCondition(stuId, 
                                                                             yearMonth.substring(0,4),
                                                                             null);

        return ResponseEntity.ok(advcPaidHistorylist);
    }

    // 执行课费预支付处理
    @CrossOrigin(origins = "*") // 它允许接受来自所有的请求，不安全，生产环境中严谨使用“*”设置。
    @PostMapping("/mb_kn_advc_pay_lsn_execute/{stuId}/{yearMonth}")
    public ResponseEntity<String> getAdvcLsnPaidHistory(@PathVariable("stuId")     String stuId,
                                                        @PathVariable("yearMonth") String yearMonth,
                                                        @RequestBody List<Kn02F003AdvcLsnFeePayBean> beans) {

        String stuName = beans.get(0).getStuName();

        List<Kn02F003AdvcLsnFeePayBean> advcPaidList = kn02F003LsnFeeAdvcPayDao.getAdvcFeePaidInfoByCondition(stuId, null, yearMonth);
        if (advcPaidList.size() > 0) {
            // 表示因为有签到了的课程，该星期所有排课撤销不可
            String errorMessage = stuName + "的" + yearMonth + "的预支付课费已经支付了，不能再重复支付。";
            return ResponseEntity.ok(errorMessage);
        }
        
        // 处理多个对象的逻辑
        for (Kn02F003AdvcLsnFeePayBean bean : beans) {
            // 对每个bean进行处理
            kn02F003LsnFeeAdvcPayDao.executeAdvcLsnFeePay(bean);
        }
        
        String successMessage = stuName + "的课费成功预支付。";
        return ResponseEntity.ok(successMessage);
    }

}
