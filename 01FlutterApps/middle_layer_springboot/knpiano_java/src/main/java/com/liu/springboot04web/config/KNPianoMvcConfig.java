package com.liu.springboot04web.config;

import com.liu.springboot04web.component.MutableLanuageLocalResolver;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

//使用WebMvcConfigurerAdapter可以来扩展SpringMVC的共功能
/*
// @EnableWebMvc//👈添加该注解，全面接管SpringMVC，自动配置就会失效
 * 在RestFulCRUD项目练习里，将@EnableWebMvc注释掉，使用SpringBoot的自动配置功能
 * */
@Configuration
public class KNPianoMvcConfig extends WebMvcConfigurerAdapter {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {

        // (@EnableWebMvc 不能标注) 启动SpringBoot，打开浏览器，在地址栏输入“http://localhost:8080/liu”即可进入“成功”页面
        registry.addViewController("/liu").setViewName("success");
    }

    /* 例子 3 在浏览器地址栏里输入 【localhost:8080】 改变默认的欢迎页面 */
    /* 20200723 场景说明开始 修改默认访问页面 第二种方式
     * 原来之前在public目录下已经有了index.html这么一个欢迎页面
     * 现在我要求，在templates目录下，也加一个首页叫index.html这么一个页面，并且，默认的页面就是templates/
     * 如何设置呢？
     * ⭐⭐⭐ 所有的WebMvcConfigurerAdapter组件都会一起起作用️
     * */
    @SuppressWarnings("deprecation")
    @Bean //⭐⭐⭐必须将组件注册在容器中，这样SpringBoot才能找到你配置的“/”或“/”
    public WebMvcConfigurerAdapter myWebMvcConfigurerAdapter() {
        WebMvcConfigurerAdapter adapter = new WebMvcConfigurerAdapter() {
            // 快捷键 command + o 挑出addViewControllers，并对该做该方法对具体实现
            @Override
            public void addViewControllers(ViewControllerRegistry registry) {
            /*在地址栏里输入【localhost:8080】回车，进入index页面
            registry.addViewController("/").setViewName("index");
            registry.addViewController("/index.html").setViewName("index");
            在地址栏里输入【localhost:8080】回车，进入index页面
            */
            registry.addViewController("/").setViewName("login");
            registry.addViewController("/login.html").setViewName("login");

            // 2020/07/28 添加一个视图映射，为的是，当点击登录按钮进入dashboard页面后，为了防止重复提交表单可以重定向到该页面
            registry.addViewController("/main.html").setViewName("dashboard");
            }

            /* 2020/07/28 在此注册component下自定义的LoginHandlerInterceptor拦截器*/
            @Override
            public void addInterceptors(InterceptorRegistry registry) {
                // 为了学习SpringBoot的错误处理机制，暂时把拦截器注释掉 2020/08/03
//                registry.addInterceptor(new LoginHandlerInterceptor()).addPathPatterns("/**").excludePathPatterns("/login.html","/","/user/login");
            }
            // addPathPatterns:添加你要拦截哪些请求。"/**":表示任意多层路径下的任意请求
            // excludePathPatterns：同时排除这三个请求，可以让非法用户访问
            /*不用担心因为拦截了任意路径下的任意请求而无法访问静态资源（比如 *.css、*.js等等的静态资源），SpringBoot已经做好了静态资源的映射处理，
             * 即便设置了"/**" ，也不会拦截静态资源，这个不必担心。 */

        };
        // 输入【http://localhost:8080/】回车，会进入classpath的templates目录下的index.html页面
        /* ⭐️️️️️️如果application.properties文件里有【server.servlet.context-path=/liu】则输入
           【http://localhost:8080/b】回车，会进入classpath的templates目录下的index.html页面 */
        return adapter;
    }
    /* 20200723 场景说明结束 修改默认访问页面 第二种方式，第一中设置方式参看
     * HelloControler.java👉public String index() */

    /* 2020/07/27
    为了使区域解析器有效，就要在config的MyMvcConfig里面为此解析器添加一个组件 */
    @Bean
    public LocaleResolver localeResolver() {
        return new MutableLanuageLocalResolver();
    }

}
