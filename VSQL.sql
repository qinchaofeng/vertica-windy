--导出数据
/opt/vertica/bin/vsql -U $usr -p 5433 -h 172.17.12.208 -w $pwd -At -o /home/zyzx/20160809.dat -c "select * from tb_test;"

--默认是以‘|’分割的，指定分隔符如下：
/opt/vertica/bin/vsql -U $usr -p 5433 -h 172.17.12.208 -w $pwd -F $'\t'  -At -o /home/zyzx/20160809.dat -c "select * from tb_test;"

--切换路径 ：\cd
dbadmin=> \!pwd
/home/zyzx
dbadmin=> \cd /tmp
dbadmin=> \!pwd
/tmp

列出多有表：\d 
列出多有函数：\df 
列出所有projection：\dj 
列出所有的schema：\dn 
列出所有的序列：\ds 
列出所有的系统字典表：\dS 
列出所有支持的类型：\dT 
列出所有的视图：\dv 
编辑sql：\e

此时会进入编辑模式，输入需要执行的sql脚本，然后保存，就可以执行了（可以同时执行多个sql语句）

执行缓存的sql：\g 
输出HTML格式的结果：\H

dbadmin=> \H
Output format is html.
dbadmin=> select * from nodes limit 1;
<table border="1">
  <tr>
    <th align="center">node_name</th>
    <th align="center">node_id</th>
    <th align="center">node_state</th>
    <th align="center">node_address</th>
    <th align="center">node_address_family</th>
    <th align="center">export_address</th>
    <th align="center">export_address_family</th>
    <th align="center">catalog_path</th>
    <th align="center">node_type</th>
    <th align="center">is_ephemeral</th>
    <th align="center">standing_in_for</th>
    <th align="center">node_down_since</th>
  </tr>
  <tr valign="top">
    <td align="left">v_csap_node0001</td>
    <td align="right">45035996273704980</td>
    <td align="left">UP</td>
    <td align="left">172.17.12.208</td>
    <td align="left">ipv4</td>
    <td align="left">172.17.12.208</td>
    <td align="left">ipv4</td>
    <td align="left">/data/CSAP/v_csap_node0001_catalog/Catalog</td>
    <td align="left">PERMANENT</td>
    <td align="left">f</td>
    <td align="left">&nbsp; </td>
    <td align="left">&nbsp; </td>
  </tr>
</table>
<p>(1 row)<br />
</p>

查看当前缓存buffer里的内容：\p

dbadmin=> \p
select * from nodes limit 1;

修改密码：\password [ USER ]

dbadmin=> \password test
Changing password for "test"
New password: 

情况当前buffer：\r

dbadmin=> \r
Query buffer reset (cleared).
dbadmin=> \p
Query buffer is empty.

历史命令查看保存为file：\s [ FILE ]

\s history.log

查看所有表的权限：\dp 或者\z

copy:
 vsql -U username -w passwd -d vmart -c "COPY store.store_sales_fact FROM STDIN DELIMITER '|';"

直接copyHDFS的文件到vertica

COPY testTable SOURCE Hdfs(url='http://hadoop:50070/webhdfs/v1/tmp/test.txt',
   username='hadoopUser');
