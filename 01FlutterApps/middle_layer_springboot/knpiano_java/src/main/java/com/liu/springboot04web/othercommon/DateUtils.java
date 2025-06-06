package com.liu.springboot04web.othercommon;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class DateUtils {

    /**
     * 获取系统日期并转换为 "yyyy/MM" 形式的字符串
     *
     * @return 格式化后的日期字符串
     */
    public static String getCurrentDateYearMonth() {
        // 获取当前系统日期
        LocalDate currentDate = LocalDate.now();
        
        // 定义目标日期格式
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM");
        
        // 格式化日期
        return currentDate.format(formatter);
    }

     /**
     * 将 Date 对象转换为 "yyyy/MM" 形式的字符串
     *
     * @param date 要转换的 Date 对象
     * @return 格式化后的日期字符串
     */
    public static String getCurrentDateYearMonth(Date date) {
  
        // 定义目标日期格式
        SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM");
        
        // 格式化日期
        return formatter.format(date);
    }

    /**
     * 将 Date 对象转换为 "yyyy/MM" 形式的字符串
     *
     * @return 年度数组
     */
    public static List<String> getYearList() {
    // 获取当前年份
        int currentYear = Calendar.getInstance().get(Calendar.YEAR);
        // 创建年份列表，从2018年开始到当前年份
        List<String> yearList = new ArrayList<>();
        for (int year = currentYear; year >= 2018; year--) {
            yearList.add(String.valueOf(year));
        }
        return yearList;
    }
}

