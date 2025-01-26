package com.liu.springboot04web;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.ViewResolver;

import java.util.Locale;

@SpringBootApplication
@MapperScan
public class SpringBoot04WebRestfulcrudApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringBoot04WebRestfulcrudApplication.class, args);
    }

    /*20200722 实验开始： 如何定制：我们可以自己给容器中添加一个视图解析器，`ContentNegotiatingViewResolver`就会自动读取到我们添加到解析器并组合进来 */
    @Bean
    public ViewResolver myViewResolver() {
        return new MyViewResolver();
    }
    private static class MyViewResolver implements ViewResolver {
        @Override
        public View resolveViewName(String viewName, Locale locale) throws Exception {
            return null;
        }
    }
    /*20200722  实验结束： 如何定制：我们可以自己给容器中添加一个视图解析器，`ContentNegotiatingViewResolver`就会自动读取到我们添加到解析器并组合进来 */
}
