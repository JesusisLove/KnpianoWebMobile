package com.liu.springboot04web.component;

import org.springframework.boot.web.error.ErrorAttributeOptions;
import org.springframework.boot.web.servlet.error.DefaultErrorAttributes;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;

import java.util.HashMap;
import java.util.Map;
@Component
// 给容器中加入我们自己定义的ErrorAttributes
public class KnErrorAttributes extends DefaultErrorAttributes {

    // MacPC：ontrol+o 弹出方法列表，选择你要重新的父类方法
    @Override // 返回的map就是页面和json能获取的所有属性信息
    public Map<String, Object> getErrorAttributes(WebRequest webRequest, ErrorAttributeOptions options) {
    Map<String, Object> map = super.getErrorAttributes(webRequest, options);
    map.put("company", "KNPiano");

    // 把我们之前在异常处理器MyExceptionHandler里自定义的map数据携带进来（搭顺风车）
    Object extraAttribute = webRequest.getAttribute("extra", 0);
    if (extraAttribute instanceof Map) {
        @SuppressWarnings("unchecked")
        Map<String, Object> myHandlerMap = (Map<String, Object>) extraAttribute;
        map.put("extra", myHandlerMap);
    } else {
        // 如果没有extra属性或类型不匹配，提供默认值
        map.put("extra", new HashMap<String, Object>());
    }
    
    return map;
}
}