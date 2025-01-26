package com.liu.springboot04web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;

import com.liu.springboot04web.bean.Kn05S002FixedLsnStatusBean;
import com.liu.springboot04web.dao.Kn05S002WeekCalculatorDao;

import java.util.List;


@Controller
public class Kn05S002WeekCalculatorController {
    @Autowired
    private Kn05S002WeekCalculatorDao kn05S002WeekCalculatorDao;
    // 【KNPiano后台维护 固定排课周次管理表】ボタンをクリック
    @GetMapping("/kn_calculate_Weeks")
    public String list(Model model) {
        List<Kn05S002FixedLsnStatusBean> collection = kn05S002WeekCalculatorDao.getInfoList();
        model.addAttribute("infoList", collection);
        // 不知道为什么这部分代码没有问题的，但是页面就是显示不出消息来。待查
        // if (model.containsAttribute("strMessage")) {
        //     Object strMessageObj = model.getAttribute("strMessage");
        //     String strMessage = (strMessageObj != null) ? strMessageObj.toString() : "null";
        //     model.addAttribute("strMessage", strMessage);
        // }

        // 用弹出提示框的方式来取代上面处理,还是显示不出消息来
        if (model.containsAttribute("apiResponse")) {
            model.addAttribute("apiResponse", model.getAttribute("apiResponse"));
        }
        return "kn_calculate_Weeks/kncalculateweeks_list";
    }

    // 执行新的年度周次的新规（一年执行一次：）
    @GetMapping("/kn_calculate_Weeks_new")
    public String calculateWeeksForYear(@RequestParam int year) {
        kn05S002WeekCalculatorDao.insertWeeksForYear(year);
        return "redirect:/kn_calculate_Weeks";
    }

    @DeleteMapping("/kn_calculate_Weeks_deleteAll")
    @ResponseBody
    public ResponseEntity<?> deleteAllWeeks() {
        try {
            /*
            // 方法一
            // 如果你想要在响应中包含一些信息，你可以这样修改：这会返回一个状态码为 200 的响应，响应体为文本 "All weeks deleted successfully"。
            return ResponseEntity.ok("All weeks deleted successfully");

            // 如果你想返回 JSON 格式的数据：这会返回一个 JSON 对象 {"message": "All weeks deleted successfully"}。
            Map<String, String> response = new HashMap<>();
            response.put("message", "All weeks deleted successfully");
            return ResponseEntity.ok(response);
            */
            kn05S002WeekCalculatorDao.deleteAll();
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error deleting all weeks");
        }
    }

    // 执行一周的固定排课计划
    @GetMapping("/kn_excute_Week_lsn_schedual/{weekStart}/{weekEnd}")
    public String excuteLsnWeeklySchedual(@PathVariable String weekStart,
                                          @PathVariable String weekEnd) {
        kn05S002WeekCalculatorDao.excuteLsnWeeklySchedual(weekStart,weekEnd);
        return "redirect:/kn_calculate_Weeks";
    }

    // 撤销一周的固定排课计划
    @GetMapping("/kn_cancel_Week_lsn_schedual/{weekStart}/{weekEnd}")
    public String cancelLsnWeeklySchedual(@PathVariable String weekStart,
                                          @PathVariable String weekEnd,
                                          RedirectAttributes redirectAttributes) {
        boolean blnProcess = kn05S002WeekCalculatorDao.cancelLsnWeeklySchedual(weekStart,weekEnd);
        ApiResponse apiResponse = new ApiResponse();
        // redirectAttributes.addFlashAttribute("strMessage", strMessage);

        if (blnProcess) {
            apiResponse.setSuccess(true);
            apiResponse.setMsgCode("CANCEL_SUCCESS");
            apiResponse.setMsgContent("撤销完成。");
        } else {
            apiResponse.setSuccess(false);
            apiResponse.setMsgCode("CANCEL_FAILURE");
            apiResponse.setMsgContent("因为已有签到排课，这批排课不能撤销。");
        }
        // 将 ApiResponse 对象存储在 RedirectAttributes 中
        redirectAttributes.addFlashAttribute("apiResponse", apiResponse);
        return "redirect:/kn_calculate_Weeks";
    }

}

 class ApiResponse {
    private boolean success;
    private String msgCode;
    private String msgContent;

    // Getter 方法
    public boolean isSuccess() {
        return success;
    }

    public String getMsgCode() {
        return msgCode;
    }

    public String getMsgContent() {
        return msgContent;
    }

    // Setter 方法
    public void setSuccess(boolean success) {
        this.success = success;
    }

    public void setMsgCode(String msgCode) {
        this.msgCode = msgCode;
    }

    public void setMsgContent(String msgContent) {
        this.msgContent = msgContent;
    }
}
