package com.liu.springboot04web.component;

import org.springframework.web.servlet.LocaleResolver;
import org.thymeleaf.util.StringUtils;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Locale;

// 可以在连接上携带区域信息，来实现国际化 2020/07/27
/*
* 为了使区域解析器有效，就要在config/MyMvcConfig里面为此解析器添加一个组件
* */
public class MutableLanuageLocalResolver implements LocaleResolver {
    @Override
    public Locale resolveLocale(HttpServletRequest request) {
        String l = request.getParameter("l");
        Locale locale = Locale.getDefault(); // 获取浏览器当前默认设置的国际化语言
        if (!StringUtils.isEmpty(l)) {
            String[] split_str = l.split("_");
            locale = new Locale(split_str[0],split_str[1]);
        }
        return locale;
    }

    @Override
    public void setLocale(HttpServletRequest request, HttpServletResponse response, Locale locale) {

    }
}