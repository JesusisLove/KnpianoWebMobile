# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**KN Piano Management System** - A Spring Boot web application for managing a piano school, including student information, lesson scheduling, fee management, and attendance tracking. The system supports both web and mobile (Flutter) clients.

## Core Technology Stack

- **Framework**: Spring Boot 2.6.6
- **Java Version**: 11
- **Database**: MySQL 8.0.33 with Druid connection pool
- **ORM**: MyBatis 2.1.3 + Spring Data JPA
- **Template Engine**: Thymeleaf
- **Frontend**: Bootstrap 4.5.0, jQuery 3.5.1

## Build and Run Commands

### Environment Setup

Before running the application, set environment variables using the provided scripts:

```bash
# Local development
source ./set_local_env.sh

# Test environment (NAS test database)
source ./set_test_env.sh

# Production environment (NAS production database)
source ./set_prod_env.sh
```

These scripts configure:
- `DB_USERNAME`, `DB_PASSWORD`, `DB_URL`: Database credentials
- `CONTEXT_PATH`: Application context path (e.g., /liu)
- `SERVER_PORT`: Application port
- `CORS_HOST`, `CORS_PORT`: CORS configuration for Flutter client

### Build and Run

```bash
# Run the application (after sourcing environment script)
mvn spring-boot:run

# Build WAR file
mvn clean package

# Run tests
mvn test

# Clean build artifacts
mvn clean
```

### Access URLs

- Web application: `http://localhost:${SERVER_PORT}${CONTEXT_PATH}`
- Example (local): `http://localhost:8080/liu`

## Project Architecture

### Package Structure

```
com.liu.springboot04web/
├── SpringBoot04WebRestfulcrudApplication.java  # Main application entry point
├── controller/           # Web UI controllers (26 controllers)
├── controller_mobile/    # REST API controllers for Flutter app (18 controllers)
├── dao/                  # Data access layer (27 DAOs)
├── mapper/              # MyBatis mapper interfaces
├── service/             # Business logic layer
├── bean/                # Entity/JavaBean classes (27+ entities)
├── config/              # Spring configuration classes
│   ├── CorsConfig.java        # CORS configuration for Flutter client
│   ├── DruidConfig.java       # Database connection pool
│   ├── MyBatisConfig.java     # MyBatis setup
│   └── KNPianoMvcConfig.java  # MVC customization
├── component/           # Interceptors and custom components
│   ├── LoginHandlerInterceptor.java
│   ├── KnErrorAttributes.java
│   └── MutableLanuageLocalResolver.java
├── handler/             # Exception handlers
│   └── KnExceptionHandler.java
├── othercommon/         # Utility classes
│   ├── DateUtils.java
│   ├── TimeZoneUtil.java
│   └── CommonProcess.java
├── waite4database/      # Database connection waiter for NAS startup
│   └── DatabaseConnectionWaiter.java
├── constant/            # Application constants
└── exception/           # Custom exceptions
```

### Controller Naming Convention

Controllers follow a hierarchical naming pattern:

- **Kn01L00X**: Lesson management (课程管理)
  - `Kn01L002LsnController`: Main lesson CRUD
  - `Kn01L002ExtraToScheController`: Convert extra lessons to scheduled lessons
  - `Kn01L003ExtraPiesesIntoOneController`: Combine lesson pieces

- **Kn02F00X**: Fee management (学费管理)
  - `Kn02F002FeeController`: Fee CRUD operations
  - `Kn02F003AdvcLsnFeePayController`: Advanced payment processing
  - `Kn02F004PayController`: Payment records
  - `Kn02F004UnpaidController`: Unpaid fee tracking
  - `Kn02f005FeeMonthlyReportController`: Monthly fee reports

- **Kn03D00X**: Data/master management (档案管理)
  - `Kn03D001StuController`: Student information
  - `Kn03D002SubController`: Subject management
  - `Kn03D003BnkController`: Bank information
  - `Kn03D004StuDocController`: Student documents

- **Kn04I00X**: Information/reporting (情报管理)
  - `Kn04I001StuWithdrawController`: Student withdrawal
  - `Kn04I002SubjectOfStudentsController`: Student subject assignments
  - `Kn04I003LsnCountingController`: Lesson statistics
  - `Kn04I004BatchLsnSignController`: Batch attendance sign-in

- **Kn05S00X**: System/tools (系统工具)
  - `Kn05S001LsnFixController`: Fix lesson data
  - `Kn05S002WeekCalculatorController`: Week number calculations

### Dual Controller Pattern

The system uses separate controllers for web and mobile:

- `controller/` - Returns HTML views (Thymeleaf templates)
- `controller_mobile/` - Returns JSON for Flutter app (suffix: `4Mobile`)

Example: `Kn01L002LsnController` vs `Kn01L002LsnController4Mobile`

### Database Layer

- **MyBatis Configuration**: `src/main/resources/mybatis/mybatis-config.xml`
- **SQL Mappers**: `src/main/resources/mybatis/mapper/*.xml`
- Naming: MyBatis XML mappers match DAO interfaces (e.g., `Kn01L002LsnDao.java` → `Kn01L002LsnMapper.xml`)

### Database Connection Retry Mechanism

The application includes a custom `DatabaseConnectionWaiter` component to handle NAS system startup scenarios where MySQL containers may start slower than the Java application. Configuration in `application.yml`:

```yaml
database:
  connection:
    max-retries: 30
    retry-interval: 10000
    total-timeout: 300000
```

## Key Configuration Details

### Timezone Handling

The application uses GMT+8 (Asia/Singapore/Shanghai) timezone:
- Configured in `application.properties`: `spring.jackson.time-zone=GMT+8`
- All `@JsonFormat` annotations in JavaBeans should use `timezone = "GMT+8"`

### CORS Configuration

CORS is configured globally via `CorsConfig.java`, not with `@CrossOrigin` annotations:
- Allowed origin is environment-specific (read from `cors.allowed-origin` property)
- Supports GET, POST, PUT, DELETE methods
- Credentials enabled for Flutter client cookie support

### Hidden Method Filter

To support RESTful PUT/DELETE requests from HTML forms:
```properties
spring.mvc.hiddenmethod.filter.enabled = true
```

### Custom Application Properties

Several business-specific properties are defined in `application.properties`:
- `lesson_durations`: Valid lesson durations (15,30,45,60,90 minutes)
- `set_durations`: Student lesson duration settings (45,60,90 minutes)
- `regular_week`: Days of week for scheduling
- `regular_hour`: Valid lesson hours (08-22)
- `regular_minute`: Valid lesson minutes (00,15,30,45)

## Development Workflow

### Making Changes to Business Logic

1. Identify the feature area by controller prefix (Kn01L, Kn02F, etc.)
2. Locate the DAO and corresponding MyBatis XML mapper
3. Update SQL in `src/main/resources/mybatis/mapper/*.xml`
4. Modify DAO interface if method signature changes
5. Update controller logic (both web and mobile if applicable)
6. Test via web UI (`templates/`) or mobile API endpoint

### Adding New Entities

1. Create JavaBean in `bean/` package
2. Use `@JsonFormat(pattern = "yyyy/MM/dd", timezone = "GMT+8")` for date fields
3. Create DAO interface in `dao/` package
4. Create MyBatis mapper XML in `src/main/resources/mybatis/mapper/`
5. Add controllers in `controller/` and/or `controller_mobile/`

### Working with Templates

- Thymeleaf templates: `src/main/resources/templates/`
- Template caching disabled in dev: `spring.thymeleaf.cache=false`
- Static resources: `src/main/resources/static/`
- Common fragments: `templates/commons/bar.html`

## Important Notes

### Date Format

The application uses `yyyy/MM/dd` format (with slashes, not dashes):
```properties
spring.mvc.format.date-time=yyyy/MM/dd
```

### MyBatis Logging

SQL statements are logged at TRACE level:
```properties
logging.level.com.liu.springboot04web.mapper=TRACE
```

### Database Initialization

SQL initialization is set to `continue-on-error: true` and `mode: never` to prevent startup failures when tables already exist.

### NAS Deployment Context

This application is designed to run in Docker containers on a NAS system where MySQL may start slower than the Java application, hence the database connection retry logic.
