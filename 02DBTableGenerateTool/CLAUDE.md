# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**KN Piano Database Tools** - A collection of database schema management tools for the KN Piano Studio Management System. This directory contains two main components:

1. **MySQL_KNStudent** - Complete MySQL database schema including DDL scripts, stored procedures, functions, and views
2. **knpiano-db-table-generator-jpa** - Spring Boot JPA application for automated table generation from Java entity classes

## Directory Structure

### 1. MySQL_KNStudent/

Complete production database schema for KNPiano system.

#### Core Components

- **TablesDDL/** - Table creation DDL scripts (19 tables)
  - Master tables: `t_mst_student`, `t_mst_subject`, `t_mst_bank`
  - Info tables: `t_info_lesson`, `t_info_lesson_fee`, `t_info_lesson_pay`, `t_info_student_document`, `t_info_subject_edaban`, `t_info_student_bank`, `t_info_fixedlesson`
  - Advanced payment: `t_info_lsn_fee_advc_pay`
  - Lesson conversion: `t_info_lesson_extra_to_sche`, `t_info_lesson_pieces_extra_to_sche`
  - Temporary tables: `t_info_lesson_tmp`
  - System tables: `sequence`, `t_sp_execution_log`, `t_batch_job_config`, `t_batch_mail_config`
  - Status tables: `t_fixedlesson_status`

- **Stored Procedures/** - 7 stored procedures
  - `sp_execute_weekly_batch_lsn_schedule` - Weekly automatic lesson scheduling
  - `sp_execute_advc_lsn_fee_pay` - Advanced payment processing
  - `sp_insert_tmp_lesson_info` - Insert temporary lesson data
  - `sp_cancel_tmp_lesson_info` - Cancel temporary lesson data
  - `sp_get_advance_pay_subjects_and_lsnschedual_info` - Get advance payment info
  - `sp_sum_unpaid_lsnfee_by_stu_and_month` - Calculate unpaid fees

- **Functions/** - 4 custom MySQL functions
  - `nextval()` - Sequence generator (PostgreSQL-style)
  - `currval()` - Get current sequence value
  - `setval()` - Set sequence value
  - `generate_weekly_date_series()` - Generate weekly date ranges

- **Views/** - 28 database views for complex queries
  - Lesson views: `v_info_lesson`, `v_info_fixedlesson`, `v_info_lesson_tmp`
  - Fee views: `v_sum_haspaid_lsnfee_by_stu_and_month`, `v_sum_unpaid_lsnfee_by_stu_and_month`
  - Payment views: `v_info_lesson_pay_over`, `v_info_lesson_sum_fee_pay_over`
  - Extra lesson conversion views: `v_info_lesson_and_extraToScheDataCorrect`, `v_info_lesson_fee_and_extraToScheDataCorrect`
  - Statistics views: `v_info_lsn_statistics_by_stuid`
  - Student views: `v_info_student_document`, `v_info_student_bank`, `v_info_subject_edaban`
  - Summary views: `v_total_lsnfee_with_paid_unpaid_every_month`

#### Production Export Files

- **prod_KNStudent_tables.sql** - Complete table DDL export from production (17,011 bytes)
- **prod_KNStudent_routines.sql** - All stored procedures and functions (37,804 bytes)
- **prod_KNStudent_views.sql** - All view definitions (56,543 bytes)

#### Utility Scripts

- **DeleteAll.sql** - Script to drop all tables, views, procedures, and functions
- **SQLite_KNPiano.sql** - SQLite version of the schema (legacy/alternative)

### 2. knpiano-db-table-generator-jpa/

Spring Boot JPA application for automatic table generation from entity classes.

**Technology Stack:**
- Spring Boot 2.3.2.RELEASE
- Spring Data JPA
- MySQL 8.0.33 connector
- Lombok 1.18.12
- Java 8

**Purpose:** This tool uses JPA annotations (@Entity, @Table, @Column) to automatically generate database DDL scripts. It's primarily used for:
- Generating initial table structures from Java entity classes
- Validating entity-database schema alignment
- Creating composite primary key classes (stored in `db_table/primarykeys/`)

**Key Configuration:**
- Server port: 8081 (to avoid conflict with main application on 8080)
- Jackson serialization: `fail-on-empty-beans=false`

## Common Development Tasks

### Working with Database Schema

#### Adding a New Table

1. Create DDL script in `MySQL_KNStudent/TablesDDL/{table_name}.sql`
2. Follow naming convention: `t_mst_*` for master data, `t_info_*` for transactional data
3. Update production export files after deployment:
   ```bash
   # Export from production database
   mysqldump -u user -p --no-data KNStudent > prod_KNStudent_tables.sql
   ```

#### Creating a New Stored Procedure

1. Create procedure in `MySQL_KNStudent/Stored Procedures/sp_{procedure_name}.sql`
2. Include execution logging using `t_sp_execution_log` table
3. Follow existing patterns for error handling and transaction management
4. Update `prod_KNStudent_routines.sql` after deployment

#### Adding a New View

1. Create view in `MySQL_KNStudent/Views/v_{view_name}.sql`
2. Use descriptive naming that reflects the view's purpose
3. Document the view's purpose with comments in the SQL file
4. Update `prod_KNStudent_views.sql` after deployment

### Using the JPA Table Generator

```bash
cd knpiano-db-table-generator-jpa

# Configure database connection in application.properties
# (typically points to a test database)

# Run the application to generate tables
mvn spring-boot:run

# JPA will automatically create/update tables based on entity annotations
```

**Important Notes:**
- The JPA generator creates tables in the configured database
- Use `spring.jpa.hibernate.ddl-auto=create` to drop and recreate tables
- Use `spring.jpa.hibernate.ddl-auto=update` to update existing tables
- Always review generated DDL before applying to production

## Database Naming Conventions

### Tables

- **Master Tables:** `t_mst_{entity}` (e.g., `t_mst_student`, `t_mst_subject`)
- **Info/Transaction Tables:** `t_info_{entity}` (e.g., `t_info_lesson`, `t_info_lesson_fee`)
- **Temporary Tables:** `t_info_{entity}_tmp`
- **System Tables:** `t_{purpose}` (e.g., `t_sp_execution_log`, `t_batch_job_config`)

### Stored Procedures

- **Prefix:** `sp_` (e.g., `sp_execute_weekly_batch_lsn_schedule`)
- **Naming:** Use descriptive verbs (execute, insert, cancel, get, sum)

### Functions

- **Naming:** Descriptive function name without prefix (e.g., `nextval`, `generate_weekly_date_series`)

### Views

- **Prefix:** `v_` (e.g., `v_info_lesson`, `v_sum_unpaid_lsnfee_by_stu_and_month`)
- **Naming:** Reflects the data source and purpose

## Critical Implementation Notes

### Sequence Management

MySQL doesn't have native sequence support like PostgreSQL. This database implements custom sequence functions (`nextval`, `currval`, `setval`) using a `sequence` table. These functions are critical for generating unique IDs across tables.

**Usage:**
```sql
INSERT INTO t_info_lesson (lesson_id, ...) VALUES (nextval('lesson_seq'), ...);
```

### Timezone Considerations

The database stores dates in UTC+0 (configured in Docker container), while the application layer (Spring Boot) uses GMT+8. All date conversions are handled in the Spring Boot application layer, NOT in the database layer.

### Production Data Safety

- **NEVER** run `DeleteAll.sql` against production database
- Always backup production data before schema changes
- Test all stored procedures in development environment first
- The `prod_KNStudent_*.sql` files are exports from production - treat them as read-only references

### Weekly Batch Scheduling

The `sp_execute_weekly_batch_lsn_schedule` stored procedure is the heart of the automatic lesson scheduling system. It:
- Runs weekly to generate upcoming lesson schedules
- Uses fixed lesson templates from `t_info_fixedlesson`
- Logs execution in `t_sp_execution_log`
- Is triggered by the Spring Boot batch job configured in `t_batch_job_config`

### Fixed Lesson Scheduling Business Rules

- All students' fixed schedules are on a **weekly** basis (one week as the scheduling unit)
- Both batch auto-scheduling and teacher's manual scheduling create lessons **one week at a time**
- Fixed schedule info is stored in `t_info_fixedlesson` table, referenced via `v_earliest_fixed_week_info` view

## Relationship to Other Projects

This database schema is used by:
- **01FlutterApps/middle_layer_springboot/knpiano_java** - Spring Boot backend application
- **01FlutterApps/front_dart_flutter** - Flutter mobile application (via Spring Boot API)

Changes to this schema typically require corresponding updates to:
1. Spring Boot entity classes (`bean/` package)
2. MyBatis mapper XML files
3. Flutter data model classes (Bean classes)

## Maintenance

### Keeping Export Files Up-to-Date

After making changes to production database:

```bash
# Tables
mysqldump -u user -p --no-data --skip-triggers KNStudent > prod_KNStudent_tables.sql

# Routines (stored procedures and functions)
mysqldump -u user -p --no-data --no-create-info --routines --skip-triggers KNStudent > prod_KNStudent_routines.sql

# Views
mysqldump -u user -p --no-data --no-create-info --skip-routines --skip-triggers KNStudent > prod_KNStudent_views.sql
```

### Version Control Best Practices

- Commit individual DDL files in `TablesDDL/`, `Stored Procedures/`, `Functions/`, `Views/` directories
- Update production export files after major releases
- Document breaking changes in commit messages
- Tag releases that correspond to production deployments
