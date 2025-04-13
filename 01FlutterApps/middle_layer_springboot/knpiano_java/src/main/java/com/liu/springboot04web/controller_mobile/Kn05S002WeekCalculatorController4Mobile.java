package com.liu.springboot04web.controller_mobile;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.liu.springboot04web.bean.Kn05S002FixedLsnStatusBean;
import com.liu.springboot04web.dao.Kn05S002WeekCalculatorDao;

import java.util.List;

@RestController
public class Kn05S002WeekCalculatorController4Mobile {

    @Autowired
    private Kn05S002WeekCalculatorDao kn05S002WeekCalculatorDao;

    @GetMapping("/mb_kn_calculate_Weeks")
    public ResponseEntity<List<Kn05S002FixedLsnStatusBean>> getStudentList() {
        // 获取未执行排课的周次
        List<Kn05S002FixedLsnStatusBean> collection = kn05S002WeekCalculatorDao.getInfoList4mb();
        return ResponseEntity.ok(collection);
    }

    // 执行新的年度周次的新规（一年执行一次：）
    @GetMapping("/mb_kn_calculate_Weeks_new")
    public void calculateWeeksForYear(@RequestParam int year) {

        // TODO 先执行删除所有去年的周次排课记录


        // 生成新年度的52周次的周排课表
        kn05S002WeekCalculatorDao.insertWeeksForYear(year);
    }

    @DeleteMapping("/mb_kn_calculate_Weeks_deleteAll")
    @ResponseBody
    public ResponseEntity<?> deleteAllWeeks() {
        try {
            /*  TODO 要执行删除所有记录的条件：
                    ①课程表里但凡有一条当前排课已经签到完毕，所有记录删除不可
                    ②如果一条签到课程都没有，再看下面条件
                        如果已经排课了，请先撤销掉所有排课，否则所有记录删除不可。
            */
            kn05S002WeekCalculatorDao.deleteAll();
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error deleting all weeks");
        }
    }

    // 执行一周的固定排课计划
    @GetMapping("/mb_kn_excute_Week_lsn_schedual/{weekStart}/{weekEnd}")
    public void excuteLsnWeeklySchedual(@PathVariable String weekStart,
                                        @PathVariable String weekEnd) {
        kn05S002WeekCalculatorDao.excuteLsnWeeklySchedual(weekStart,weekEnd);
    }

    // 撤销一周的固定排课计划
    @GetMapping("/mb_kn_cancel_Week_lsn_schedual/{weekStart}/{weekEnd}/{weekNumber}")
    public ResponseEntity<String> cancelLsnWeeklySchedual(@PathVariable String weekStart,
                                                          @PathVariable String weekEnd,
                                                          @PathVariable int weekNumber,
                                                          RedirectAttributes redirectAttributes) {
        if ( kn05S002WeekCalculatorDao.cancelLsnWeeklySchedual(weekStart,weekEnd)) {
            return ResponseEntity.ok("ok");
        } else {
        // 表示因为有签到了的课程，该星期所有排课撤销不可
        return ResponseEntity.ok("因为已有签到排课，第" + weekNumber + "周的排课不能撤销。");
        }
    }
}
