package com.liu.springboot04web.component;
/*2020/07/28 Springboot 学习
 * 使用拦截器进行登录检查
 * 为什么要用拦截器？
 * 打开浏览器，输入【localhost：8080/liu】，进入到login画面，输入正确的用户名和密码登录成功后进入主页面，地址栏显示【http://localhost:8080/b/main.html】
 * 将主页面的URL复制粘贴到google的chrome浏览器回车，也能进入主页面，这是不允许的，为了解决这个问题，就用拦截器
 * */
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
/*
* 拦截器的作用就是，登录检查；对于那些没有登录的用户，不能访问后台的主页main.html
* */
public class LoginHandlerInterceptor implements HandlerInterceptor {
    // 目标方法执行之前，做一个预检查，看看当前登录的用户存不存在
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        Object user = request.getSession().getAttribute("loginUser");
        if (user == null) {
            // 当前用户未登录，在别的浏览器访问当前url时，进行拦截，禁止通行，返回登录页面

            // 将非法用户的请求转发出去，并在页面上显示错误消息
            request.getRequestDispatcher("/login.html").forward(request,response);
            request.setAttribute("msg","没有权限，请先登录");
            return false;
        } else {
            // 当前用户已登录，在别的浏览器访问当前url时，放行允许通过
            return true;
        }
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }
}
