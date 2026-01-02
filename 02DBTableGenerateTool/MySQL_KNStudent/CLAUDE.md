# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the MySQL database schema repository for **KNPiano Student Management System** (prod_KNStudent database). It's part of a larger 3-tier architecture:
- Frontend: Flutter mobile/web app (../../01FlutterApps/front_dart_flutter/)
- Backend: Spring Boot REST API (../../01FlutterApps/middle_layer_springboot/knpiano_java/)
- Database: MySQL schemas defined in this repository

The system manages piano school operations including student enrollment, lesson scheduling, fee management, and payment tracking.

## Repository Structure

```
MySQL_KNStudent/
├── prod_KNStudent.sql          # Main deployment script (2599 lines) - USE THIS for full DB setup
├── SQLite_KNPiano.sql          # Legacy SQLite schema (reference only)
├── DeleteAll.sql               # Development utility to clear all data
├── TablesDDL/                  # Individual table definitions (18+ tables)
├── Views/                      # Database views (20+ views)
├── Functions/                  # Custom MySQL functions (4 functions)
└── Stored Procedures/          # Business logic procedures (4+ procedures)
```

## Working with Database Objects

### Critical Execution Order

**IMPORTANT**: Views, functions, and procedures have interdependencies. Always follow this order when deploying:

1. **Functions first** (required by procedures and views):
   - nextval(), currval(), setval() - Custom sequence generators (MySQL lacks native sequences)
   - generate_weekly_date_series() - Date range generator for batch scheduling

2. **Tables** (master → transaction tables):
   - Master tables: t_mst_student, t_mst_subject, t_mst_bank
   - Info tables: t_info_subject_edaban, t_info_student_bank, t_info_student_document
   - Transaction tables: t_info_lesson, t_info_lesson_fee, t_info_lesson_pay

3. **Views** (have strict dependency order - see prod_KNStudent.sql lines 22-42):
   - Base views: v_info_subject_edaban, v_info_student_bank, v_info_fixedlesson
   - Lesson views: v_info_lesson, v_info_lesson_include_extra2sche
   - Fee calculation views: v_sum_unpaid_lsnfee_by_stu_and_month, v_total_lsnfee_with_paid_unpaid_every_month

4. **Stored Procedures** (depend on views and functions):
   - sp_execute_weekly_batch_lsn_schedule - Auto-generates lesson schedules for a week
   - sp_execute_advc_lsn_fee_pay - Processes advance fee payments
   - sp_get_advance_pay_subjects_and_lsnschedual_info - Retrieves payment schedule data

### Deployment Commands

**Full database setup**:
```bash
mysql -u root -p prod_KNStudent < prod_KNStudent.sql
```

**Individual component update**:
```bash
# Update a specific table
mysql -u root -p prod_KNStudent < TablesDDL/t_info_lesson.sql

# Update a specific view
mysql -u root -p prod_KNStudent < Views/v_info_lesson.sql

# Update a specific function
mysql -u root -p prod_KNStudent < Functions/generate_weekly_date_series.sql

# Update a specific stored procedure
mysql -u root -p prod_KNStudent < "Stored Procedures/sp_execute_weekly_batch_lsn_schedule.sql"
```

**Development cleanup** (clears all data but preserves schema):
```bash
mysql -u root -p prod_KNStudent < DeleteAll.sql
```

## Architecture Insights

### Custom Sequence Implementation

MySQL doesn't have native sequences like PostgreSQL. This database implements sequences via:
- `sequence` table stores current values
- `nextval(seqid)` - Generates next ID (thread-safe with row locking)
- `currval(seqid)` - Returns current value without incrementing
- `setval(seqid, value)` - Resets sequence to specific value

Sequence prefixes:
- 'kn-stu-' - Student IDs
- 'kn-sub-' - Subject IDs
- 'kn-lsn-' - Lesson IDs
- 'kn-fee-' - Fee IDs
- 'kn-pay-' - Payment IDs

### Key Data Model Concepts

**Extra Lessons (零碎課)**: Short/irregular lessons that can be combined into regular lessons
- `t_info_lesson_extra_to_sche` - Tracks extra lessons converted to scheduled lessons
- `t_info_lesson_pieces_extra_to_sche` - Tracks pieces of multiple extra lessons combined
- Views with `_include_extra2sche` suffix include both regular and converted extra lessons

**Lesson Types** (`lesson_type` in t_info_lesson):
- Regular scheduled lessons
- Extra/makeup lessons
- Combined lessons (from multiple extra lessons)

**Payment Tracking**:
- `t_info_lesson_fee` - Lesson fees owed
- `t_info_lesson_pay` - Payment records (can be partial or overpayment)
- Views like `v_sum_unpaid_lsnfee_by_stu_and_month` aggregate unpaid amounts
- `v_info_lesson_sum_fee_pay_over` tracks overpayments to apply to future fees

**Fixed Lesson Scheduling**:
- `t_info_fixedlesson` - Recurring weekly lesson templates
- `t_fixedlesson_status` - Tracks batch schedule generation status
- `sp_execute_weekly_batch_lsn_schedule` - Auto-generates lessons from templates

### View Modification History

The `Views/` directory contains a subdirectory `2025-02-24_修改视图文件(同月出现不同子科目的BUG)/` with backup files. When modifying complex views (especially fee calculation views), check this history for context on bug fixes.

## Common Development Tasks

When modifying schema objects:

1. **Always update both individual file AND prod_KNStudent.sql**:
   - Edit the specific file in TablesDDL/, Views/, Functions/, or Stored Procedures/
   - Update the corresponding section in prod_KNStudent.sql (main deployment file)

2. **Test view changes**: Many views depend on each other. After changing a view:
   ```bash
   # Drop and recreate dependent views in order
   mysql -u root -p prod_KNStudent < prod_KNStudent.sql
   ```

3. **Adding new sequences**: Update Functions/nextval.sql AND add INSERT to sequence table section in prod_KNStudent.sql (around line 79-86)

4. **Procedure logging**: Stored procedures use `t_sp_execution_log` for execution tracking. Check this table when debugging batch jobs.

## Integration with Application Layers

**Spring Boot Backend**:
- DAO classes query views (not raw tables) for complex data
- Example: `Kn01L002ExtraToScheDao.java` references views like `v_info_lesson_include_extra2sche`
- Stored procedures called via JdbcTemplate or @Procedure annotations

**Flutter Frontend**:
- Consumes REST APIs from Spring Boot
- Configuration in `../../01FlutterApps/front_dart_flutter/kn-vpn-config/apiconfig.json`
- UI displays aggregated data from database views

**Recent Frontend Additions (2025-12-31)**:
- **加课处理报告页面** (`Kn02F006ExtraLsnReport.dart`):
  - Displays extra lesson statistics for all students in a selected year
  - Shows paid/unpaid/converted lesson counts by subject
  - Features:
    - Subject-level filtering (not student-level totals)
    - Real-time statistics (student count, subject count)
    - Visual feedback: selected filter categories maintain original colors, unselected turn grey
    - Year selector with optimized layout
  - API endpoint: `GET /liu/mb_kn_extratosche_all/{stuId}/{year}` (uses stuId="ALL" for all students)
  - Performance: Optimized from N+1 requests to single request

## Database Naming Conventions

- Tables: `t_mst_*` (master), `t_info_*` (transactional), `t_batch_*` (config)
- Views: `v_*`
- Stored Procedures: `sp_*`
- Columns: snake_case with suffixes (_id, _date, _flg, _name, _type)
- Japanese comments explain business logic; use these to understand table purposes

## Git Workflow

Recent commits show active development on:
- Extra lesson combination features (零碎課拼整課)
- Lesson statistics by student
- Payment tracking improvements

When committing schema changes, use commit format:
`🔳[Device]: [Component] - [Changes in Chinese]`
