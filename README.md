# scripts_for_healthcheck

Collection of Oracle Database and E-Business Suite health check scripts for monitoring database status, tablespaces, backups, archive logs, and performance metrics.

These scripts are derived from real-time production support scenarios in Oracle EBS environments.

## Oracle DB Health Check Scripts

This repository contains health check scripts used in real-world Oracle Database and E-Business Suite (EBS) environments.

## 📌 Features
- Database Status Check
- Tablespace Usage Monitoring
- Backup Status Verification


## 🛠️ Technologies
- Oracle Database (11g/12c/19c)
- Oracle E-Business Suite (R12)
- Shell Scripting (Linux)

## 📂 Scripts Included
- hc.sql → SQL-based database health check script
- archive_cleanup.sh → Archive log cleanup (to be added)
- session_monitor.sql → Active session monitoring (to be added)

## 🚀 Usage

Run the script using SQL*Plus:

```sql
sqlplus / as sysdba
@hc.sql



##👤 Author

Syed Anwar Ahmed
Oracle Apps DBA
Oracle ACE Apprentice


