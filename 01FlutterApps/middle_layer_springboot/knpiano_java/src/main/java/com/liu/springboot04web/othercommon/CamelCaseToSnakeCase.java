package com.liu.springboot04web.othercommon;

import java.util.HashMap;
import java.util.Map;

public class CamelCaseToSnakeCase {

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



}