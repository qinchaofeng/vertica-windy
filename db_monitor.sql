
-- database status,Normal UP
select node_name,node_state,node_type,is_ephemeral,standing_in_for,node_down_since from nodes order by node_name;

-- epoch & wos,Normal current_epoch,ahm_epoch,last_good_epoch it's a small difference.
select current_epoch,ahm_epoch,last_good_epoch,current_fault_tolerance,wos_used_bytes,wos_row_count from system;

-- hosts resources, Normal disk_free_percent(%)>=40%
select host_name,processor_description,processor_count,processor_core_count,total_memory_bytes,total_memory_free_bytes,disk_space_free_mb,disk_space_used_mb,disk_space_total_mb,(disk_space_free_mb/disk_space_total_mb*100)::varchar(5) as 'disk_free_percent(%)' from host_resources order by 1;

-- disk usage on servers,Normal disk_free_percent(%)>=40%
select node_name,storage_path,disk_space_used_mb,disk_space_free_mb,disk_space_free_percent from disk_storage order by 5;

-- cpu usage on servers,Normal avg_cpu_usage<=85%
select node_name,(now() - ${Days} ) from_time,now(),min(average_cpu_usage_percent) min_cpu_usage,max(average_cpu_usage_percent) max_cpu_usage,avg(average_cpu_usage_percent) avg_cpu_usage from cpu_usage where start_time between now() - ${Days} and now() group by 1,2,3 order by 5 desc;

-- io usage on servers
select node_name,(now() - ${Days} ) from_time,now(),min(read_kbytes_per_sec) min_read_kb_per_sec,max(read_kbytes_per_sec) max_read_kb_per_sec,avg(read_kbytes_per_sec) avg_read_kb_per_sec,min(written_kbytes_per_sec) min_written_kb_per_sec,max(written_kbytes_per_sec) max_written_kb_per_sec,avg(written_kbytes_per_sec) avg_written_kb_per_sec from io_usage where start_time between now() - ${Days} and now() group by 1,2,3 order by 1;

-- mem usage on servers
select node_name,(now() - ${Days} ) from_time,now(),min(average_memory_usage_percent) min_mem_usage,max(average_memory_usage_percent) max_mem_usage,avg(average_memory_usage_percent) avg_mem_usage from memory_usage where start_time between now() - ${Days} and now() group by 1,2,3 order by 1;

-- net usage on servers
select node_name,(now() - ${Days} ) from_time,now(),min(tx_kbytes_per_sec) min_tx_kb_per_sec,max(tx_kbytes_per_sec) max_tx_kb_per_sec,avg(tx_kbytes_per_sec) avg_tx_kb_per_sec,min(rx_kbytes_per_sec) min_rx_kb_per_sec,max(rx_kbytes_per_sec) max_rx_kb_per_sec,avg(rx_kbytes_per_sec) avg_rx_kb_per_sec from network_usage where start_time between now() - ${Days} and now() group by 1,2,3 order by 1;

-- total table count in database till now,Normal total_table_count<=1.2w
select now(),count(*) as total_table_count from tables;

-- created table's count in last ${Days} days
select trunc(create_time,'DD') as 'day',count(*) created_table_count from tables where create_time between now() - ${Days} and now() group by 1 order by 1;

-- created table's list in last ${Days} days
select table_schema,table_name,owner_name,is_temp_table,force_outer,is_flextable,partition_expression,create_time from tables where create_time between now() - ${Days} and now() order by create_time;

-- catalog size,统计一周数据历史数据，日增长不超过历史日增长值
SELECT
    node_name,
    now()                   AS TIMESTAMP,
    MAX(catalog_size_in_MB) AS Catalog_size_in_MB
FROM
    (
        SELECT
            node_name,
            SUM((dc_allocation_pool_statistics_by_second.total_memory_max_value -
            dc_allocation_pool_statistics_by_second.free_memory_min_value))/(1024*1024) AS
            Catalog_size_in_MB
        FROM
            dc_allocation_pool_statistics_by_second
        GROUP BY
            1,
            TRUNC((dc_allocation_pool_statistics_by_second."time")::TIMESTAMP,'SS'::VARCHAR(2)) )
    foo
GROUP BY
    1
ORDER BY
    3;

-- get session status,统计一周数据历史数据，会话数不超过历史日均会话数
select (now() - ${Days}) from_date,
  now(),
  user_name, 
  count(1) total_cnt,
  sum(case when current_statement != '' then 1 else 0 end) active_cnt 
from sessions 
where login_timestamp::timestamp >now() - ${Days}
group by 1,2,3
order by 5 desc;

-- lock status,Normal request_timestamp >= now() -  ${Days}
select now(),
  node_names, 
  object_name, 
  lock_mode, 
  request_timestamp, 
  SUBSTR(TO_CHAR(transaction_description), 0, 100) query
from locks;


-- total history min & max & avg execute time in last 1 day,统计历史数据，不超过历史均值
select (now() - ${Days}) from_date,
  now(),
  count(1) total_exec_sql,
  min(query_duration_us//1000) min_ms,
  max(query_duration_us//1000) max_ms,
  avg(query_duration_us//1000) avg_ms
from query_profiles
where query_start::timestamp > now() - ${Days}
group by 1,2
order by 1,2
;

-- history min & max & avg execute time in last 1 day according user_name,统计历史数据，不超过历史均值
select (now() - ${Days}) from_date,
  now(),
  user_name,
  count(1) total_exec_sql,
  min(query_duration_us//1000) min_ms,
  max(query_duration_us//1000) max_ms,
  avg(query_duration_us//1000) avg_ms
from query_profiles
where query_start::timestamp > now() - ${Days}
  and query not like 'SET'
group by 1,2,3
order by 7 desc
;

-- get history min & max & avg execute time in last 1 day according query_type,统计历史数据，不超过历史均值
select (now() - ${Days}) from_date,
  now(),
  query_type,
  count(1) total_exec_sql,
  min(query_duration_us//1000) min_ms,
  max(query_duration_us//1000) max_ms,
  avg(query_duration_us//1000) avg_ms
from query_profiles
where query_start::timestamp > now() - ${Days}
group by 1,2,3
order by 7 desc
;

-- get history min & max & avg execute time in last 1 day according query,统计历史数据，不超过历史均值
select (now() - ${Days}) from_date,
  now(),
  query,
  count(1) as times,
  avg(query_duration_us//1000) as avg_ms,
  min(query_duration_us//1000) min_ms,
  max(query_duration_us//1000) max_ms,
  sum(query_duration_us//1000) as total_ms
from query_profiles
where query_start::timestamp > now() - ${Days}
group by 1,2,3
order by 4 desc
limit 100
;

-- get resource pool runing sql
select node_name,
  pool_name,
  memory_inuse_kb,
  running_query_count 
from resource_pool_status 
where running_query_count > 0 
  and not is_internal 
order by 2 desc,3 desc;

-- top 5 sql
SELECT distinct
  (now() - ${Days}) from_date,
  now(),
  --ra.node_name,
  qp.user_name,
  ra.pool_name,
  --qp.session_id,
  qp.transaction_id,
  qp.statement_id                                     stat_id,
  trunc(qp.query_start::TIMESTAMP, 'SS')              query_start,
  TO_CHAR(qp.query_duration_us // 1000, '9,999,999')  dur_ms,
  ra.memory_inuse_kb // 1024                          mem_inuse_mb,
  qp.processed_row_count                              r_cnt,
  qp.query as                                         sql
FROM query_profiles qp INNER JOIN RESOURCE_ACQUISITIONS ra USING (transaction_id, statement_id)
WHERE qp.query_start::TIMESTAMP > now() - ${Days}
  and not qp.is_executing
  --AND qp.user_name not IN ('dbadmin')
ORDER BY 6 DESC, 3 limit 5
;

-- check segment layout, normally there should be only 2 different types ***
select now(),
  substr(segexpr, instr(segexpr, 'implicit range: ')+length('implicit range: ')) as range, 
  count(1) as cnt 
from vs_segments 
group by 1,2 
order by 2;

-- Projection status,找出min_size，max_size相差最大的记录数（min_size/max_size比值小于0.8）
select projection_schema||'.'||projection_name,
 trunc(sum(row_count)/100000000,0) total_row_count,
 trunc(sum(used_bytes)/(1024*1024*1024),0) total_size,
 trunc(max(used_bytes)/(1024*1024*1024),0) max_size,
 trunc(min(used_bytes)/(1024*1024*1024),0) min_size,
 count(1) node_count
 from projection_storage where row_count!=0 group by 1 order by 2 desc limit 10;


