package com.liu.springboot04web.othercommon;

import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import java.util.List;
import java.util.Locale;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.time.DayOfWeek;
import java.time.format.TextStyle;



public class CommonProcess {

    /* 对Map里的key值做转换更改：将Bean的项目值改成表字段的项目值。例如:bankId该换成bank_id */
    public static Map<String, Object> convertToSnakeCase(Map<String, Object> inputMap) {
        Map<String, Object> outputMap = new HashMap<>();
        for (Map.Entry<String, Object> entry : inputMap.entrySet()) {
            String camelCaseKey = entry.getKey();
            StringBuilder snakeCaseKey = new StringBuilder();
            for (char ch : camelCaseKey.toCharArray()) {
                if (Character.isUpperCase(ch)) {
                    snakeCaseKey.append("_").append(Character.toLowerCase(ch));
                } else {
                    snakeCaseKey.append(ch);
                }
            }
            outputMap.put(snakeCaseKey.toString(), entry.getValue());
        }
        return outputMap;
    }


    /* 传递一个Map<String, String>，要求返回一个对Map<String, String>的value值按照升序排列好的Map */
    public static Map<String, String> sortMapByValues(Map<String, String> map) {
        // 将Map的值转换为列表
        List<Map.Entry<String, String>> entryList = new ArrayList<>(map.entrySet());

        // 使用Collections.sort方法对列表进行排序，根据值升序排序
        Collections.sort(entryList, new Comparator<Map.Entry<String, String>>() {
            public int compare(Map.Entry<String, String> o1, Map.Entry<String, String> o2) {
                return o1.getValue().compareTo(o2.getValue());
            }
        });

        // 创建一个新的LinkedHashMap，用于存储排序后的键值对
        LinkedHashMap<String, String> sortedMap = new LinkedHashMap<>();
        for (Map.Entry<String, String> entry : entryList) {
            sortedMap.put(entry.getKey(), entry.getValue());
        }

        return sortedMap;
    }

    /* 使用HashSet去除List<String>数组里的重复项 */ 
    public static List<String> removeDuplicates(List<String> inputList) {
        // 使用HashSet去除重复项
        Set<String> uniqueElements = new HashSet<>(inputList);
        
        // 将Set转换回List
        return new ArrayList<>(uniqueElements);
    }

    /* 把没有顺序的WeekDay，按照周一到周日的顺序排列 */ 
    public static List<String> sortWeekdays(List<String> unsortedDays) {
        Locale locale = Locale.US;  // 设定Locale，这决定了星期名称的本地化表达

        // 创建一个映射，将星期简称映射到DayOfWeek枚举
        final var dayMap = Arrays.stream(DayOfWeek.values())
                .collect(Collectors.toMap(
                        day -> day.getDisplayName(TextStyle.SHORT, locale),
                        day -> day
                ));

        // 对列表进行排序，根据DayOfWeek的自然顺序
        return unsortedDays.stream()
                .sorted(Comparator.comparing(dayMap::get))
                .collect(Collectors.toList());
    }
}