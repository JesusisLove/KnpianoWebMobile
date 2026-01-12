# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Ruby Scripts** - A collection of Ruby utility scripts for the KN Piano Studio Management System. Currently contains test and utility scripts.

## Current Contents

### index.rb

A simple "Hello World" Ruby script for testing Ruby environment setup.

```ruby
# 输出一个hello world的语句
puts "hello world"
```

**Usage:**
```bash
ruby index.rb
```

## Purpose

This directory serves as a placeholder for future Ruby utility scripts that may be needed for:
- Data migration scripts
- Batch processing utilities
- System administration tasks
- Database maintenance scripts
- Report generation tools

## Development Notes

### Ruby Version

Ensure you have Ruby installed on your system:
```bash
# Check Ruby version
ruby --version

# Install Ruby if needed (macOS with Homebrew)
brew install ruby
```

### Adding New Scripts

When adding new Ruby scripts to this directory:

1. **File Naming:** Use lowercase with underscores (e.g., `data_migration_tool.rb`)
2. **Encoding:** Add UTF-8 encoding comment at the top of files with Chinese comments:
   ```ruby
   # encoding: utf-8
   ```
3. **Documentation:** Add clear comments explaining the script's purpose and usage
4. **Dependencies:** If using gems, create a `Gemfile`:
   ```ruby
   source 'https://rubygems.org'
   gem 'mysql2'  # Example dependency
   ```

### Common Use Cases

Future scripts in this directory might include:

- **Database Migration:** Scripts to migrate data between different database versions
- **Batch Updates:** Mass updates to student records or lesson data
- **Data Import/Export:** Converting data between formats (CSV, JSON, SQL)
- **System Maintenance:** Cleanup scripts, archive old data
- **Report Generation:** Custom reports that don't fit in the main application

## Relationship to Other Projects

This directory is independent but may interact with:
- **02DBTableGenerateTool/MySQL_KNStudent/** - Database scripts for data operations
- **01FlutterApps/middle_layer_springboot/knpiano_java** - May generate data for or process data from the Spring Boot application

## Best Practices

- Keep scripts focused on a single task
- Use command-line arguments for configurable parameters
- Add error handling and validation
- Log operations for audit trails
- Test scripts thoroughly before running against production data
- Document any database connections or external dependencies
