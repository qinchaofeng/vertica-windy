--Sets the scaling factor that determines the number of storage containers used when rebalancing the database and when using local data segmentation is enabled. 

dbadmin=> select * from elastic_cluster;
-[ RECORD 1 ]------------+------------------------------------------------------------------------------------------------
scaling_factor           | 4
maximum_skew_percent     | 15
segment_layout           | v_vmart_node0001[100.0%]
local_segment_layout     | v_vmart_node0001[25.0%] v_vmart_node0001[25.0%] v_vmart_node0001[25.0%] v_vmart_node0001[25.0%]
version                  | 0
is_enabled               | t
is_local_segment_enabled | f
is_rebalance_running     | f


select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;

node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  35         
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          26         
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           28         

select do_tm_task('mergeout','kafka_store_orders_fact.stream_microbatch_history');
Task: mergeout
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_super)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_top1)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_DBD_1_seg_scheduler_design_b0)
  
select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;
node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  1          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          1          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           1          

dbadmin=> SELECT ENABLE_LOCAL_SEGMENTS();
 ENABLE_LOCAL_SEGMENTS
-----------------------
 ENABLED
(1 row)

select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;
node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  3          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          3          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           1          

select do_tm_task('mergeout','kafka_store_orders_fact.stream_microbatch_history');
Task: mergeout
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_super)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_top1)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_DBD_1_seg_scheduler_design_b0)

select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;
node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  4         
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          4         
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           1          






dbadmin=> SELECT disABLE_LOCAL_SEGMENTS();
 DISABLE_LOCAL_SEGMENTS
-----------------------
 DISABLED
(1 row)

dbadmin=> SELECT SET_SCALING_FACTOR(12);
-[ RECORD 1 ]------+----
SET_SCALING_FACTOR | SET

select do_tm_task('mergeout','kafka_store_orders_fact.stream_microbatch_history');
Task: mergeout
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_super)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_top1)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_DBD_1_seg_scheduler_design_b0)
  
select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;
node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  1          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          1          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           1          

dbadmin=> SELECT ENABLE_LOCAL_SEGMENTS();
 ENABLE_LOCAL_SEGMENTS
-----------------------
 ENABLED
(1 row)

select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;
node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  5          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          4          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           7          

select do_tm_task('mergeout','kafka_store_orders_fact.stream_microbatch_history');
Task: mergeout
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_super)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_top1)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_DBD_1_seg_scheduler_design_b0)

select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;
node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  12         
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          12         
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           2          


select do_tm_task('mergeoutsingleros', 'kafka_store_orders_fact.stream_microbatch_history');
Task: mergeout to single ros
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_super)
(Table: kafka_store_orders_fact.stream_microbatch_history) (Projection: kafka_store_orders_fact.stream_microbatch_history_DBD_1_seg_scheduler_design_b0)




dbadmin=> select * from elastic_cluster;
-[ RECORD 1 ]------------+------------------------------------------------------------------------------------------------
scaling_factor           | 4
maximum_skew_percent     | 15
segment_layout           | v_vmart_node0001[100.0%]
local_segment_layout     | v_vmart_node0001[25.0%] v_vmart_node0001[25.0%] v_vmart_node0001[25.0%] v_vmart_node0001[25.0%]
version                  | 0
is_enabled               | t
is_local_segment_enabled | t
is_rebalance_running     | f

select node_name, projection_schema, projection_name, SUM(ros_count) AS ros_count from v_monitor.projection_storage where anchor_table_name = 'stream_microbatch_history' group by 1,2,3 order by 3;
node_name         projection_schema        projection_name                                          ros_count  
----------------  -----------------------  -------------------------------------------------------  ---------  
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_DBD_1_seg_scheduler_design_b0  4          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_super                          4          
v_vmart_node0001  kafka_store_orders_fact  stream_microbatch_history_top1                           2          





