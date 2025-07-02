package com.liu.springboot04web.othercommon;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
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

    /**
     * 方法1: 灵活解析日期格式并比较（推荐）
     * 自动识别日期格式并比较两个日期，只比较到年月日
     * @param firstDate 可能的格式: yyyy-MM-dd 或 yyyy-MM-dd HH:mm
     * @param secondDate 可能的格式: yyyy-MM-dd 或 yyyy-MM-dd HH:mm
     * @return 如果firstDate <= secondDate返回true，否则返回false
     */
    public static boolean compareDatesMethod1(String firstDate, String secondDate) {
        // 解析第一个日期，自动识别格式
        LocalDate date1 = parseToLocalDate(firstDate);
        
        // 解析第二个日期，自动识别格式
        LocalDate date2 = parseToLocalDate(secondDate);
        
        // 比较：date1 <= date2
        return !date1.isAfter(date2);
    }
    
    /**
     * 辅助方法：自动识别日期格式并转换为LocalDate
     * @param dateString 日期字符串，格式可能是 yyyy-MM-dd 或 yyyy-MM-dd HH:mm
     * @return LocalDate对象
     */
    private static LocalDate parseToLocalDate(String dateString) {
        if (dateString == null || dateString.trim().isEmpty()) {
            throw new IllegalArgumentException("日期字符串不能为空");
        }
        
        dateString = dateString.trim();
        
        try {
            // 尝试解析为 yyyy-MM-dd HH:mm 格式
            if (dateString.contains(" ") && dateString.length() > 10) {
                LocalDateTime dateTime = LocalDateTime.parse(dateString, 
                    DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"));
                return dateTime.toLocalDate();
            } else {
                // 解析为 yyyy-MM-dd 格式
                return LocalDate.parse(dateString, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("无法解析日期格式: " + dateString + 
                ". 支持的格式: yyyy-MM-dd 或 yyyy-MM-dd HH:mm", e);
        }
    }
    
    /**
     * 方法2: 如果bean返回的是Date对象
     * @param firstDate Date对象
     * @param secondDate Date对象
     * @return 如果adjustedDate <= schedualDate返回true，否则返回false
     */
    public static boolean compareDatesMethod2(Date firstDate, Date secondDate) {
        // 将Date转换为LocalDate进行比较
        LocalDate date1 = firstDate.toInstant()
                .atZone(java.time.ZoneId.systemDefault())
                .toLocalDate();
        
        LocalDate date2 = secondDate.toInstant()
                .atZone(java.time.ZoneId.systemDefault())
                .toLocalDate();
        
        return date1.isBefore(date2) || date1.isEqual(date2);
    }
}

