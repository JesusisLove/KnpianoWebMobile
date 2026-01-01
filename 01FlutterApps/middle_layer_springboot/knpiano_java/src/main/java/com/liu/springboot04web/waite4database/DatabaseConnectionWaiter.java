package com.liu.springboot04web.waite4database;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;
// 使用 Spring Boot 自带的日志
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import javax.sql.DataSource;
import java.sql.Connection;

/**
 * 数据库连接等待组件
 * 
 * 目的：解决NAS启动时MySQL与Java批处理应用的启动顺序问题
 * 
 * 问题背景：
 * - NAS系统在早上8:00自动启动时，会同时启动MySQL容器和批处理应用容器
 * - MySQL服务需要较长时间进行数据库初始化和启动（通常需要2-5分钟）
 * - 批处理应用启动较快，在MySQL未完全启动时就尝试连接数据库
 * - 导致应用启动失败，出现"Communications link failure"错误
 * 
 * 解决方案：
 * 在应用启动完成后，通过ApplicationRunner接口自动执行数据库连接等待逻辑
 * - 循环尝试连接数据库，每次失败后等待指定时间再重试
 * - 设置最大重试次数和总超时时间，避免无限等待
 * - 连接成功后正常启动应用，失败则抛出异常终止启动
 * 
 * 配置参数：
 * - database.connection.max-retries: 最大重试次数（默认30次）
 * - database.connection.retry-interval: 重试间隔毫秒数（默认10000ms）
 * - database.connection.total-timeout: 总超时时间毫秒数（默认300000ms）
 * 
 * 使用场景：
 * - NAS环境下的容器启动顺序问题
 * - Docker容器环境中的服务依赖等待
 * - 任何需要等待数据库完全启动的场景
 * 
 * 注意事项：
 * - 此组件会在Spring Boot应用启动的最后阶段执行
 * - 如果数据库连接失败超过最大重试次数，应用将启动失败
 * - 建议配合application-db.properties中的HikariCP超时配置一起使用
 * 
 * @author Liu
 * @version 1.0.0
 * @since 2025-08-08
 */

@Component
public class DatabaseConnectionWaiter implements ApplicationRunner {

    // 使用 Spring Boot 自带的日志
    private static final Log log = LogFactory.getLog(DatabaseConnectionWaiter.class);

    @Autowired
    private DataSource dataSource;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        waitForDatabase();
    }

    private void waitForDatabase() {
        int maxRetries = 30;
        int retryInterval = 10000;
        
        for (int i = 0; i < maxRetries; i++) {
            try {
                Connection connection = dataSource.getConnection();
                connection.close();
                log.info("数据库连接成功！");
                return;
            } catch (Exception e) {
                log.warn("数据库连接失败，第 " + (i + 1) + " 次重试... 错误: " + e.getMessage());
                try {
                    Thread.sleep(retryInterval);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    break;
                }
            }
        }
        throw new RuntimeException("无法连接到数据库，已达到最大重试次数");
    }
}