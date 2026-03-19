

-- ============================================
-- Oracle Database Health Check Script
-- Author: Syed Anwar Ahmed
-- Description: Basic health check for DB status,
--              tablespaces, sessions, and backups
-- ============================================


set colsep '|';
 set lines 1200
 col HOST_NAME for a12
 select name,open_mode,log_mode,controlfile_type,instance_name,host_name,database_role, to_char(STARTUP_TIME,'DD-MON-YYYY HH24:MI:SS') "DB UP TIME"from v$database, v$instance;
!hostname;date

set lines 200 pages 200
col session_key for 999999;
col start_time for a20;
col end_time for a20;
col output_bytes_display for a30;
col time_taken_display for a30;
select session_key,
       input_type,
       status,
       to_char(start_time,'yyyy-mm-dd hh24:mi') start_time,
       to_char(end_time,'yyyy-mm-dd hh24:mi')   end_time,
       output_bytes_display,
       time_taken_display
from v$rman_backup_job_details
where
    start_time > SYSDATE -3
order by session_key asc;

col owner for a20
select owner,count(object_name) from dba_objects where status='INVALID' group by owner;

set lines 200 pages 100
set colsep |
column TABLESPACE_NAME format A30   heading "TableSpace|Name"
column CUR_ALLOC       format 9999999 heading "Current|Allocated"
column CUR_USED        format 9999999 heading "Current|Used"
column CUR_FREE        format 9999999 heading "Current|Free"
column CUR_PCT_FULL    format 9999999 heading "Current|PCT|Full"
column MAX_ALLOC       format 999999999 heading "Maximum|Allocated"
column MAX_FREE        format 999999999 heading "Maximum|Free"
column MAX_PCT_FULL    format 9999999 heading "Maximum|PCT|Full"
column FILES           format 9999999 heading "Files"
column FREE_CHUNKS     format 9999999 heading "Free|Chunk"
column MAX_CHUNK       format 9999999 heading "Maximum|Chunk"
  select
        df.tablespace_name "TABLESPACE_NAME"
       ,round(df.bytes/1024/1024/1024) "CUR_ALLOC"
       ,round((df.bytes-nvl(fs.bytes,0))/1024/1024/1024) "CUR_USED"
       ,nvl(round(fs.bytes/1024/1024/1024),0) "CUR_FREE"
       ,round((df.bytes-nvl(fs.bytes,0))/df.bytes,2)*100 "CUR_PCT_FULL"
       ,round(mb.bytes/1024/1024/1024) "MAX_ALLOC"
       ,round((mb.bytes-(df.bytes-nvl(fs.bytes,0)))/1024/1024/1024,0) "MAX_FREE"
       ,round((df.bytes-nvl(fs.bytes,0))/mb.bytes,2)*100 "MAX_PCT_FULL"
      from (select
             tablespace_name
            ,sum(bytes) bytes
            ,sum(maxbytes) maxbytes
            ,count(*) files
        from
             sys.dba_data_files
      group by
             tablespace_name) df
     ,(select tablespace_name
             ,sum(bytes) bytes
             ,count(*) chunks
             ,round(max(bytes)/1024/1024/1024,0) max_chunk
         from
              dba_free_space
      group by
              tablespace_name) fs
      ,(select tablespace_name
              ,sum(decode(maxbytes,0,bytes,maxbytes)) bytes
          from sys.dba_data_files
         group by tablespace_name) mb
where
      df.tablespace_name=fs.tablespace_name (+)
  and df.tablespace_name=mb.tablespace_name
--and df.tablespace_name like 'SAUX'
  order by 8;

set colsep |
column TABLESPACE_NAME format A30   heading "TableSpace|Name"
column CUR_ALLOC       format 9999999 heading "Current|Allocated"
column CUR_USED        format 9999999 heading "Current|Used"
column CUR_FREE        format 9999999 heading "Current|Free"
column CUR_PCT_FULL    format 9999999 heading "Current|PCT|Full"
column MAX_ALLOC       format 999999999 heading "Maximum|Allocated"
column MAX_FREE        format 999999999 heading "Maximum|Free"
column MAX_PCT_FULL    format 9999999 heading "Maximum|PCT|Full"
column FILES           format 9999999 heading "Files"
column FREE_CHUNKS     format 9999999 heading "Free|Chunk"
column MAX_CHUNK       format 9999999 heading "Maximum|Chunk"
  select
        df.tablespace_name "TABLESPACE_NAME"
       ,round(df.bytes/1024/1024/1024) "CUR_ALLOC"
       ,round((df.bytes-nvl(fs.bytes,0))/1024/1024/1024) "CUR_USED"
       ,nvl(round(fs.bytes/1024/1024/1024),0) "CUR_FREE"
       ,round((df.bytes-nvl(fs.bytes,0))/df.bytes,2)*100 "CUR_PCT_FULL"
       ,round(mb.bytes/1024/1024/1024) "MAX_ALLOC"
       ,round((mb.bytes-(df.bytes-nvl(fs.bytes,0)))/1024/1024/1024,0) "MAX_FREE"
       ,round((df.bytes-nvl(fs.bytes,0))/mb.bytes,2)*100 "MAX_PCT_FULL"
      from (select
             tablespace_name
            ,sum(bytes) bytes
            ,sum(maxbytes) maxbytes
            ,count(*) files
        from
             sys.dba_data_files
      group by
             tablespace_name) df
     ,(select tablespace_name
             ,sum(bytes) bytes
             ,count(*) chunks
             ,round(max(bytes)/1024/1024/1024,0) max_chunk
         from
              dba_free_space
      group by
              tablespace_name) fs
      ,(select tablespace_name
              ,sum(decode(maxbytes,0,bytes,maxbytes)) bytes
          from sys.dba_data_files
         group by tablespace_name) mb
where
      df.tablespace_name=fs.tablespace_name (+)
  and df.tablespace_name=mb.tablespace_name
and df.tablespace_name like '%UNDO%'
  order by 8;

SELECT   A.tablespace_name tablespace, D.Gb_total,
         SUM (A.used_blocks * D.block_size) / 1024 / 1024 /1024 Gb_used,
         D.Gb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 / 1024 Gb_free
FROM     v$sort_segment A,
         (
         SELECT   B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 /1024 Gb_total
         FROM     v$tablespace B, v$tempfile C
         WHERE    B.ts#= C.ts#
         GROUP BY B.name, C.block_size
         ) D
WHERE    A.tablespace_name = D.name
GROUP by A.tablespace_name, D.Gb_total;

SELECT tablespace_name, status, COUNT(*) AS HOW_MANY
FROM dba_undo_extents
GROUP BY tablespace_name, status;




set colsep '|'
set lines 200
set pages 200
col segment_name for a20
select owner,segment_name,tablespace_name, sum(bytes)/1024/1024 size_mb, sum(bytes)/1024/1024/1024 size_gb from dba_segments
where segment_name='CFLPR_CAPTURE_STG' group by owner,segment_name, tablespace_name;




prompt
prompt =====================================================================
SET DEFINE ON

column Name format a17
SELECT Name, (SPACE_LIMIT/1024/1024/1024) Space_Limit_GB, SPACE_USED/1024/1024/1024 Space_Used_GB, SPACE_RECLAIMABLE, NUMBER_OF_FILES
FROM V$RECOVERY_FILE_DEST;

col name for a32
col size_m for 999,999,999
col used_m for 999,999,999
col pct_used for 999

SELECT name
,       ceil( space_limit / 1024 / 1024) SIZE_M
,       ceil( space_used  / 1024 / 1024) USED_M
,       decode( nvl( space_used, 0),
        0, 0
        , ceil ( ( space_used / space_limit) * 100) ) PCT_USED
FROM v$recovery_file_dest
ORDER BY name
/
set lines 220;
col value for a80;
select * from v$diag_info;
!lsnrctl status LISTENER
!df -h
!sh alert.sh

