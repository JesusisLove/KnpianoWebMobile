# KnpianoWebMobile

## 项目简介

KnpianoWebMobile是一个基于Flutter+SpringBoot+MySQL的钢琴1对1教学，老师个人使用的管理系统，用于管理自己学生的信息、课程安排、学费收缴等小型业务的App应用。

## 技术栈

- **前端**: Flutter (支持移动设备的前端应用)和Thymeleaf（Web端的数据维护及管理）
- **后端**: Spring Boot + MyBatis
- **数据库**: MySQL 8.0+

## 项目结构

```
KnpianoWebMobile/
├── 01FlutterApps/
│   ├── front_dart_flutter/           # Flutter前端应用
│   └── middle_layer_springboot/      # Spring Boot中间层API
└── 02DBTableGenerateTool/
    └── MySQL_KNStudent/              # MySQL数据库脚本
```

### 1. front_dart_flutter (Flutter前端)
- 学生管理、课程管理、学费管理等功能模块
- 支持移动端和Web端多端运行
- API配置: `kn-vpn-config/apiconfig.json`

### 2. middle_layer_springboot (Spring Boot后端)
- RESTful API服务
- MyBatis数据访问层
- 业务逻辑处理

### 3. MySQL_KNStudent (数据库)
- 完整的数据库表结构定义
- 视图、存储过程、函数、触发器
- 详见 `02DBTableGenerateTool/MySQL_KNStudent/CLAUDE.md`

## 最近更新

### 2025年12月31日
- ✅ **新增加课处理报告页面** (`Kn02F006ExtraLsnReport.dart`)
  - 显示所有学生的加课统计（已支付/未支付/已转换）
  - 支持科目级别过滤和实时统计
  - 优化布局和视觉反馈，提升用户体验
  - 性能优化：从N+1次请求优化为单次请求

### 2024年12月29日
- 修复学费重复显示问题并优化43节课统计逻辑
- 自动设置银行默认值功能优化

### 2024年12月28日
- 修复Bug4学费重复显示问题

## 开发历史

### 2024年3月
- ✅ 前端Flutter框架搭建完成
- ✅ 中间层Spring Boot框架搭建完成
- ✅ MySQL数据库环境搭建完成

### 2024年3月31日
- 建立KnPianoWebMobile的存储桶（Repository）

## 相关文档

- Flutter前端详细文档: 待补充
- Spring Boot API文档: 待补充
- 数据库设计文档: `02DBTableGenerateTool/MySQL_KNStudent/CLAUDE.md`
