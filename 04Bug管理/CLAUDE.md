# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**KN Piano Studio Management System** is a comprehensive 3-tier web/mobile application for managing a one-on-one piano teaching studio in Singapore. The system handles lesson scheduling, student records, fee management, attendance tracking, and financial reporting.

**Tech Stack**: Flutter + Spring Boot + MySQL
**Language**: Chinese (UI and comments)
**Started**: March 2024

## Repository Structure

```
KnpianoWebMobile/
├── 01FlutterApps/
│   ├── front_dart_flutter/           # Flutter mobile/web app
│   └── middle_layer_springboot/      # Spring Boot backend
│       └── knpiano_java/
├── 02DBTableGenerateTool/
│   └── MySQL_KNStudent/              # Database schema & scripts
├── 03RubyFiles/                      # Ruby scripts (minimal usage)
└── CLAUDE.md                         # This file
```

Each major component has its own detailed CLAUDE.md file:
- [Flutter Frontend CLAUDE.md](01FlutterApps/front_dart_flutter/CLAUDE.md)
- [Spring Boot Backend CLAUDE.md](01FlutterApps/middle_layer_springboot/knpiano_java/CLAUDE.md)
- [Database CLAUDE.md](02DBTableGenerateTool/MySQL_KNStudent/CLAUDE.md)

## System Architecture

```
Flutter App (Mobile/Web)
    │ HTTP REST API (JSON)
    ↓
Spring Boot Backend (Java 11)
    │ JDBC via MyBatis + Druid Pool
    ↓
MySQL 8.0.33 Database
```

### Three-Tier Architecture

1. **Presentation Layer**: Flutter app with 5 feature modules (Lesson, Fee, Student Doc, Integrated, Settings)
2. **Business Layer**: Spring Boot with dual controllers (web HTML + mobile JSON)
3. **Data Layer**: MySQL with tables, views, functions, and stored procedures

## Common Development Commands

### Flutter Frontend

```bash
cd 01FlutterApps/front_dart_flutter

# Install dependencies
flutter pub get

# Run app (development)
flutter run

# Build for production
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web

# Code quality
flutter analyze
flutter format .
flutter test
```

**Environment Switching**:
Edit `pubspec.yaml` lines 68-73 to comment/uncomment the desired API config:
- `kn-local-config/apiconfig.json` - Local development
- `kn-nas-test-config/apiconfig.json` - NAS test
- `kn-nas-config/apiconfig.json` - NAS production (currently active)
- `kn-vpn-config/apiconfig.json` - VPN environment

### Spring Boot Backend

```bash
cd 01FlutterApps/middle_layer_springboot/knpiano_java

# Set environment variables first (REQUIRED)
source ./set_local_env.sh     # Local
source ./set_test_env.sh      # Test
source ./set_prod_env.sh      # Production

# Run application
mvn spring-boot:run

# Build JAR
mvn clean package

# Run tests
mvn test
```

**Environment Variables Required**:
- `DB_USERNAME`, `DB_PASSWORD`, `DB_URL` - Database connection
- `CONTEXT_PATH`, `SERVER_PORT` - Server config
- `CORS_HOST`, `CORS_PORT` - CORS settings

### Database Schema

```bash
cd 02DBTableGenerateTool/MySQL_KNStudent

# Full database setup (drops and recreates everything)
mysql -u root -p prod_KNStudent < prod_KNStudent.sql

# Individual component updates
mysql -u root -p prod_KNStudent < TablesDDL/t_info_lesson.sql
mysql -u root -p prod_KNStudent < Views/v_info_lesson.sql
mysql -u root -p prod_KNStudent < Functions/generate_weekly_date_series.sql
mysql -u root -p prod_KNStudent < "Stored Procedures/sp_execute_weekly_batch_lsn_schedule.sql"

# Development: Clear all data
mysql -u root -p prod_KNStudent < DeleteAll.sql
```

**CRITICAL**: Database objects must be deployed in order:
1. Functions first (required by views and procedures)
2. Tables (master tables before transactional tables)
3. Views (dependency order matters - see prod_KNStudent.sql lines 22-42)
4. Stored procedures last

## Key Architectural Patterns

### 1. Feature-Based Module Structure (Flutter)

The Flutter app is organized into 5 independent modules, each with a dedicated color theme:

```
lib/
├── 01LessonMngmnt/       # Lesson Management (上课管理) - Green
├── 02LsnFeeMngmnt/       # Fee Management (学费管理) - Pink
├── 03StuDocMngmnt/       # Student Documents (档案管理) - Brown
├── 04IntegratMngmnt/     # Integrated Management (综合管理) - Purple
└── 05SettingMngmnt/      # Settings (设置管理) - Purple-blue
```

Navigation: `main.dart` → `HomePage.dart` (bottom nav bar) → Module pages

### 2. Dual Controller Pattern (Spring Boot)

Two separate controller packages serve different clients:

- **`controller/`** (26 controllers) - Returns HTML views via Thymeleaf for web UI
- **`controller_mobile/`** (18 controllers) - Returns JSON for Flutter app

Both share the same service/DAO layers for code reuse.

**Naming Convention**: `Kn{Module}{Sequence}{Feature}Controller[4Mobile]`
- `Kn01L002LsnController` - Web HTML controller
- `Kn01L002LsnController4Mobile` - Mobile JSON controller

**Module Prefixes**:
- `Kn01L00X` - Lesson Management (课程管理)
- `Kn02F00X` - Fee Management (学费管理)
- `Kn03D00X` - Data/Master Management (档案管理)
- `Kn04I00X` - Information/Reporting (情报管理)
- `Kn05S00X` - System/Tools (系统工具)

### 3. Bean Pattern for Data Models

All data models follow the "Bean" pattern:

**Flutter**:
```dart
class Kn01L002LsnBean {
  String lessonId;
  String studentName;
  DateTime lessonDate;

  factory Kn01L002LsnBean.fromJson(Map<String, dynamic> json) {
    return Kn01L002LsnBean(
      lessonId: json['lessonId'],
      studentName: json['studentName'],
      lessonDate: CommonMethod.parseServerDate(json['lessonDate']),
    );
  }
}
```

**Spring Boot**:
```java
public class Kn01L002LsnBean {
    private String lessonId;
    private String studentName;

    @JsonFormat(pattern = "yyyy/MM/dd HH:mm:ss", timezone = "GMT+8")
    private Date lessonDate;
}
```

### 4. View-Based Database Queries

Complex queries are encapsulated in database views rather than constructing SQL in code:

- DAOs query views (e.g., `v_info_lesson`) instead of raw tables
- Views handle joins, aggregations, and business logic
- Easier to maintain and optimize performance

### 5. Custom Sequence Implementation

MySQL doesn't have native sequences, so a custom implementation is used:

```sql
-- Generate next ID
SELECT nextval('kn-lsn-')  -- Returns 'kn-lsn-0001', 'kn-lsn-0002', etc.

-- Sequence prefixes:
-- 'kn-stu-' - Student IDs
-- 'kn-sub-' - Subject IDs
-- 'kn-lsn-' - Lesson IDs
-- 'kn-fee-' - Fee IDs
-- 'kn-pay-' - Payment IDs
```

See [Functions/nextval.sql](02DBTableGenerateTool/MySQL_KNStudent/Functions/nextval.sql)

## Critical Implementation Details

### Timezone Handling (EXTREMELY IMPORTANT)

**The Problem**:
- Server runs in Docker container set to **UTC+0** (not GMT+8)
- Physical server location is Singapore (GMT+8)
- Flutter app expects proper timezone conversion

**Flutter Solution**:
```dart
// Always use CommonMethod.parseServerDate() for dates from server
DateTime lessonDate = CommonMethod.parseServerDate(dateString);

// This appends "+0000" timezone to the date string
// Example: "2025-12-11 14:00" → "2025-12-11 14:00 +0000"
```

See [CommonProcess/CommonMethod.dart:34-63](01FlutterApps/front_dart_flutter/lib/CommonProcess/CommonMethod.dart#L34-L63)

**Spring Boot Configuration**:
```properties
spring.jackson.time-zone=GMT+8
```

All `@JsonFormat` annotations on Date fields use `timezone = "GMT+8"`.

**Never modify timezone handling without understanding the full data flow!**

### API Endpoint Management

**Centralized in Flutter**: All API endpoints are defined in [Constants.dart](01FlutterApps/front_dart_flutter/lib/Constants.dart) (280+ lines)

When adding a new endpoint:
1. Add constant in `Constants.dart`
2. Use as: `${KnConfig.apiBaseUrl}${Constants.yourEndpoint}`

**API Base URL** is loaded dynamically from environment-specific JSON config at app startup.

### Database Connection Retry Mechanism

**Why Needed**: On NAS startup, MySQL container starts slower than Spring Boot app

**Solution**: Custom retry logic in `DatabaseConnectionWaiter` component
- Max retries: 30 attempts
- Retry interval: 10 seconds
- Total timeout: 5 minutes

Configuration in [application.yml](01FlutterApps/middle_layer_springboot/knpiano_java/src/main/resources/application.yml):
```yaml
spring:
  datasource:
    druid:
      initialization-fail-timeout: 300000  # 5 min
      fail-fast: false

database:
  connection:
    max-retries: 30
    retry-interval: 10000
```

### CORS Configuration

**Global CORS** is configured in [CorsConfig.java](01FlutterApps/middle_layer_springboot/knpiano_java/src/main/java/com/liu/springboot04web/config/CorsConfig.java) using environment variable `cors.allowed-origin`.

**Do not add** `@CrossOrigin` annotations on individual controllers - use the global config.

## Typical Development Workflow

### Adding a New Feature

**1. Database Layer**:
```bash
cd 02DBTableGenerateTool/MySQL_KNStudent

# Create table SQL
vim TablesDDL/t_info_new_feature.sql

# Create view SQL (if needed)
vim Views/v_info_new_feature.sql

# Add to deployment script
vim prod_KNStudent.sql  # Add in correct order

# Deploy
mysql -u root -p prod_KNStudent < prod_KNStudent.sql
```

**2. Spring Boot Backend**:
```bash
cd 01FlutterApps/middle_layer_springboot/knpiano_java

# Create Bean
vim src/main/java/com/liu/springboot04web/bean/KnXXNewFeatureBean.java

# Create DAO interface
vim src/main/java/com/liu/springboot04web/dao/KnXXNewFeatureDao.java

# Create MyBatis mapper XML
vim src/main/resources/mybatis/mapper/KnXXNewFeatureMapper.xml

# Create mobile controller
vim src/main/java/com/liu/springboot04web/controller_mobile/KnXXNewFeatureController4Mobile.java

# Test
source ./set_local_env.sh
mvn spring-boot:run
```

**3. Flutter Frontend**:
```bash
cd 01FlutterApps/front_dart_flutter

# Add API endpoint constant
vim lib/Constants.dart

# Create Bean class
vim lib/XX_ModuleName/KnXXNewFeatureBean.dart

# Create page widget
vim lib/XX_ModuleName/KnXXNewFeaturePage.dart

# Add navigation (if new page)
vim lib/HomePage.dart  # Or parent page

# Test
flutter run
```

### Making Database Schema Changes

**Always follow this sequence**:

1. Modify SQL file in `TablesDDL/` or `Views/`
2. Update `prod_KNStudent.sql` with the change
3. Deploy to database
4. Update corresponding Bean classes in Spring Boot
5. Update Flutter Bean class if API response changes
6. Test the full stack

**Do not** modify database schema directly in MySQL without updating SQL files!

## Configuration Management

### Environment-Specific Settings

**Flutter**: Switch environment by editing `pubspec.yaml` (lines 68-73)

**Spring Boot**: Source appropriate environment script before running:
```bash
source ./set_local_env.sh      # localhost:8080, local DB
source ./set_test_env.sh       # NAS test DB (192.168.50.101:49168)
source ./set_prod_env.sh       # NAS production DB
```

**Database**: Connection string set via `DB_URL` environment variable

### Date Format Conventions

**Consistency is critical across all layers**:

- **MySQL**: `YYYY-MM-DD HH:mm:ss` (ISO format)
- **Spring Boot**: `yyyy/MM/dd HH:mm:ss` (with slashes in JSON, configured in application.properties)
- **Flutter Display**: `yyyy/MM/dd HH:mm` (formatted via `intl` package)
- **API Communication**: ISO format with timezone handling

## Key Data Model Concepts

### Extra Lessons (零碎课)

Short or irregular lessons that can be combined into regular lessons:

- **Tables**:
  - `t_info_lesson_extra_to_sche` - Tracking extra lessons
  - `t_info_lesson_pieces_extra_to_sche` - Lesson fragment details
- **Views**: Views with `_include_extra2sche` suffix include both regular and converted lessons
- **Controllers**: `Kn01L002ExtraToScheController` handles conversion logic

### Lesson Types

1. **Regular scheduled lessons** - Normal weekly lessons
2. **Extra/makeup lessons** - One-off or irregular lessons
3. **Combined lessons** - Created from multiple extra lesson fragments

### Payment Tracking

- **`t_info_lesson_fee`** - Fees owed for lessons
- **`t_info_lesson_pay`** - Payment records (can be partial or overpayment)
- **Views** - Aggregate unpaid amounts and track overpayments

### Fixed Lesson Scheduling

- **`t_info_fixedlesson`** - Recurring weekly lesson templates
- **`t_fixedlesson_status`** - Batch generation status tracking
- **Stored Procedure**: `sp_execute_weekly_batch_lsn_schedule` - Auto-generates lessons from templates

## Technology Dependencies

### Flutter
```yaml
flutter: 3.19.3
dart: >=3.3.1 <4.0.0
http: ^1.2.1              # REST API
intl: ^0.19.0             # Date formatting
table_calendar: ^3.1.2    # Calendar UI
fl_chart: ^0.68.0         # Charts
logger: ^1.1.0            # Logging
```

### Spring Boot
```xml
Spring Boot: 2.6.6
Java: 11
MySQL Connector: 8.0.33
MyBatis: 2.1.3
Druid: 1.2.22
Thymeleaf: (for web UI)
```

### Database
```
MySQL: 8.0.33
```

## Common Gotchas

1. **Don't forget to source environment script** before running Spring Boot (`source ./set_local_env.sh`)

2. **Database deployment order matters** - Functions must be deployed before views and procedures

3. **Timezone handling is fragile** - Always use `CommonMethod.parseServerDate()` in Flutter for server dates

4. **Environment switching in Flutter** requires editing `pubspec.yaml` and rebuilding the app

5. **Controller naming**: Mobile controllers must end with `4Mobile` suffix

6. **Date format in Spring Boot**: Uses slashes (`yyyy/MM/dd`) not dashes in JSON output

7. **Custom sequences**: Use `nextval('prefix-')` function, not MySQL AUTO_INCREMENT

8. **CORS is global** - Don't add `@CrossOrigin` annotations

9. **MyBatis mappers**: Must be in `mybatis/mapper/*.xml` and interface must have `@Mapper` annotation

10. **NAS deployment**: Allow 5 minutes for MySQL container to start before Spring Boot connects

## Git Branch Strategy

- **Main branch**: `main`
- **Current development branch**: `knpiano_20250715`

When creating commits, follow the existing pattern:
```
🔳MacStudio : [Brief description in Chinese]
- Detail 1
- Detail 2
```

## Additional Resources

- Git status shows recent commits with detailed change descriptions
- Each component has its own detailed CLAUDE.md file
- Database schema has extensive inline SQL comments
- Application logs in Spring Boot provide debugging context
