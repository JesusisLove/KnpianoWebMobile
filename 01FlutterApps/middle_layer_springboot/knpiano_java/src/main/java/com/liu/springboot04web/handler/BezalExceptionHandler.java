package com.liu.springboot04web.handler;

/*
 *  在其他客户端（比如手机等）访问出现异常的时候，返回的是json数据
 *  如果不想使用系统的异常规则的情况下，如何自定制一个自己的异常规则，
 *  本class就是指定自己的异常规则
 * */

import com.liu.springboot04web.exception.UserNotExistException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import java.nio.file.attribute.UserPrincipalNotFoundException;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice  // 👈在SpringMVC中，要成为异常处理器，它（本class）得是一个ControllerAdvice
public class BezalExceptionHandler {

//    @ResponseBody
//    @ExceptionHandler(UserNotExistException.class)
    //这么一写，PC客户端和其他（如手机客户端）都显示json格式的错误信息，这个组件没有自适应功能的
//    public Map<String,Object> handleException(Exception e) {
//
//        Map<String,Object> map = new HashMap<>() ;
//        map.put("code","user not exist");
//        map.put("message",e.getMessage());
//        return map;
//    }
    /*如何改造成自适应的功能效果呢？
    * SpringMVC在错误的自动配置类（ErrorMvcAutoConfiguration）里面提供了类BasicErrorController
    *@RequestMapping("${server.error.path:${error.path:/error}}")👈 记住，处【/error】
    *public class BasicErrorController extends AbstractErrorController {
    *
    * @RequestMapping(produces = MediaType.TEXT_HTML_VALUE)👈 👇 该组件是处理PC客户端error请求的
    * public ModelAndView errorHtml(HttpServletRequest request, HttpServletResponse response) {
    *
    * @RequestMapping👈 👇 该组件是处理PC客户端以外其他客户端（如手机客户端）error请求的
	* public ResponseEntity<Map<String, Object>> error(HttpServletRequest request) {
    *
    * 根据SpringMVC提供的这两个组件，我就可以把当前的错误做成一个自适应的
    * */

    // 扩展成自适应效果的组件
    @ExceptionHandler(UserNotExistException.class)
    public String handleException(Exception e, HttpServletRequest request) {

        // 传入我们自己设定的错误状态码：4xx，5xx等
        request.setAttribute("javax.servlet.error.status_code",567);//为了验证确实是自己设置的

        Map<String,Object> map = new HashMap<>() ;
        map.put("code","user not exist");
        map.put("message","哎呀！用户不存在呀！！");
        request.setAttribute("extra",map);

        // 转发给【/error】让BasicErrorController给我们进行自适应处理
        return "forward:/error";
    }
}