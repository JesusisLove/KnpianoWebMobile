# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Claude Code 使用规范

### 一、角色定义

**Claude Code 不是决策者，只是辅助者。**

- 任何需要确认的问题，都必须提出来由用户来决定，而不是 Claude Code 自行决定
- Claude Code 要积极提案，但最终由用户来决定是否采纳
- 绝对禁止未经用户同意自行修改或追加代码

### 二、代码修改规范

在修改或追加代码之前，必须：
1. 先向用户提问："需要我修改代码吗？" 或 "需要我追加代码吗？"
2. 等待用户明确指示后，方可执行
3. 禁止在未获得用户许可的情况下，自行修改或追加任何代码

### 三、开发方法论

#### 3.1 设计文档与代码的一致性

- **详细设计书的业务逻辑必须和代码实现一致**
- 在实装代码前，必须先阅读相关的详细设计文档
- 如果发现设计文档与代码不一致，必须向用户报告

#### 3.2 测试用例编写规范

- **测试用例必须覆盖所有与功能相关的代码分支**
- 测试用例的编写必须基于：
  1. 详细设计文档的业务逻辑
  2. 实际代码的实现逻辑
- 禁止凭想象编写测试用例

### 四、工作流程

1. **理解需求** → 阅读相关设计文档和现有代码
2. **提出方案** → 向用户说明计划，等待用户确认
3. **获得许可** → 用户同意后方可执行
4. **执行任务** → 按照用户确认的方案执行
5. **汇报结果** → 向用户报告执行结果

---

## Project Overview

**KNPiano Web & Mobile** - The main application repository containing:

1. **01FlutterApps/** - Flutter mobile application and Spring Boot backend
   - `front_dart_flutter/` - Flutter mobile app (iOS/Android)
   - `middle_layer_springboot/knpiano_java/` - Spring Boot backend (Java 21)

2. **02DBTableGenerateTool/** - Database schema management tools
   - `MySQL_KNStudent/` - Complete MySQL database schema
   - `knpiano-db-table-generator-jpa/` - JPA-based table generator

3. **03RubyFiles/** - Legacy Ruby scripts (not actively used)

## Key Technologies

- **Frontend**: Flutter/Dart
- **Backend**: Spring Boot 2.7.18 + MyBatis
- **Database**: MySQL 8.0.33
- **Build**: Maven (Java), Flutter SDK (Dart)

## Build Commands

### Spring Boot Backend
```bash
cd 01FlutterApps/middle_layer_springboot/knpiano_java
mvn clean package
java -jar target/knpiano-0.0.1-SNAPSHOT.jar
```

### Flutter Mobile App
```bash
cd 01FlutterApps/front_dart_flutter
flutter pub get
flutter run
```

## Architecture

- Backend runs on port 8080 (configurable via SERVER_PORT)
- Uses MyBatis for database access
- RESTful API design for mobile-backend communication
- Thymeleaf templates for Web UI
