package com.liu.springboot04web.config;

import com.alibaba.druid.pool.DruidDataSource;
import com.alibaba.druid.support.http.StatViewServlet;
import com.alibaba.druid.support.http.WebStatFilter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class DruidConfig {
    @Bean
    @ConfigurationProperties(prefix = "spring.datasource")// 把在yaml或properties文件里所有"spring.datasource"的属性绑定进来
    public DataSource druidDataSource() {
        return new DruidDataSource();
    }

    /* 配置Druid的监控 */
    // 1 配置一个管理后台的Servlet
    @Bean // 把return出来的bean加入到容器中
    public ServletRegistrationBean statViewServlet() {
        ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean(new StatViewServlet(),"/druid/*");

        // 对servletRegistrationBean做一些配置
        Map<String,String> initParams = new HashMap<>();
        initParams.put("loginUsername","root"); // 登录后台时用的用户名
        initParams.put("loginPassword","admin"); // 登录后台时用的密码
        // initParams.put("allow","localhost"); // 表示只有本地才可以访问Druid的后台监控数据源
        initParams.put("allow",""); // 表示允许所有访问
        //initParams.put("deny","192.168.15.21"); // 表示拒绝192.168.15.21的用户访问
        /*   👉ResourceServlet.java
            public static final String SESSION_USER_KEY = "druid-user";
            public static final String PARAM_NAME_USERNAME = "loginUsername";
            public static final String PARAM_NAME_PASSWORD = "loginPassword";
            public static final String PARAM_NAME_ALLOW = "allow";
            public static final String PARAM_NAME_DENY = "deny";
            public static final String PARAM_REMOTE_ADDR = "remoteAddress";
        */

        servletRegistrationBean.setInitParameters(initParams);
        return servletRegistrationBean;
    }

    // 2 配置一个web监控的filter
    @Bean
    public FilterRegistrationBean webStatFilter() {
        FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean();
        filterRegistrationBean.setFilter(new WebStatFilter());
        // 对filterRegistrationBean做一些配置
        Map<String,String> initParams = new HashMap<>();
        // 用初始化参数的方式，告诉拦截器不拦截哪些静态资源下的请求
        initParams.put("exclusions","*.js,*.css,/druid/*");

        filterRegistrationBean.setInitParameters(initParams);
        filterRegistrationBean.setUrlPatterns(Arrays.asList("/*"));// 拦截所有请求

        return filterRegistrationBean;
    }

}
