#!/usr/bin/bash 
#安装percona的源
sudo yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
#安装Percona-XtraDB-Cluster-57 
sudo yum -y install Percona-XtraDB-Cluster-57

IP_ADDRESS=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g'  | awk -F' ' '{print $2}' | grep -v 32 | awk -F'/' '{print $1}')
num=`ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | grep -v 172 | grep -v 32 | awk -F'/' '{print $1}' | awk -F"." '{print $4}'`
echo "********************** 当前本机IP地址为：${IP_ADDRESS} 此脚本需要在每台电脑上执行 **********************"
echo "新建mysql的数据目录"
mkdir -p /home/mysqldata/mysql

echo -n "请输入master节点的IP:"
read master

echo -n "请输入slave1节点的IP:"
read slave1

echo -n "请输入slave2节点的IP:"
read slave2

echo -n "请输入要设置的mysql的密码"
read passwd

function choice(){
	echo -n "请选择节点(1.master;2.slave1;3.slave2)"
        read choice 
        if [[ ${choice} == "1" ]];then 
            echo "选择了master"
            
#生成master的配置文件
cat <<EOF > /etc/my.cnf 
#
# The Percona XtraDB Cluster 5.7 configuration file.
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#   Please make any edits and changes to the appropriate sectional files
#   included below.
#
!includedir /etc/my.cnf.d/
!includedir /etc/percona-xtradb-cluster.conf.d/

[mysqld]
federated
basedir=/data/mysqldata/mysql
datadir=/data/mysqldata/mysql
user=mysql

slow_query_log=1
binlog_format=ROW  #基于ROW复制（安全可靠）
binlog_cache_size = 2M
max_binlog_size=256M
long_query_time =2
log-queries-not-using-indexes=0
back_log=2048     #设置会话请求缓存个数
sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO,STRICT_ALL_TABLES
lower_case_table_names=1
transaction_isolation=READ-COMMITTED

default_storage_engine=innodb #默认引擎
innodb_autoinc_lock_mode=2  #主键自增长不锁表
innodb_flush_method=O_DIRECT #设置innodb数据文件及redo log的打开、刷写模式
innodb_buffer_pool_size=18G  #设置buffer pool size,一般为服务器内存60%
innodb_buffer_pool_instances=16 #设置buffer pool instance个数，提高并发能力
innodb_max_dirty_pages_pct=90
innodb_log_buffer_size=12M #设置log buffer size大小
innodb_log_file_size=512M #设置logfile大小
innodb_log_files_in_group=4 #设置logfile组个数
innodb_autoextend_increment=128
innodb_flush_log_at_trx_commit=1 #每次事务提交时Percona都会把log buffer的数据写入log file，并且flush（刷到磁盘）中去
innodb_open_files=4000 #设置最大打开表个数

max_allowed_packet=500M
connect_timeout=300


# connection limit has been reached.
max_connections=2000 #设置最大连接数
max_connect_errors=1200
open_files_limit=65535
table_open_cache = 600
table_definition_cache=600
performance_schema_max_table_instances=1024
tmp_table_size = 1024M
thread_cache_size = 256


# Set the query cache.
query_cache_size = 1G
query_cache_type = ON
query_cache_limit= 4M

max_heap_table_size= 1024M
max_allowed_packet = 32M
max_heap_table_size = 8M

# buffer size
key_buffer_size = 1024M
read_buffer_size = 4M
sort_buffer_size = 4M
join_buffer_size = 4M
read_rnd_buffer_size=4M
sync_binlog=1 #设置每次sync_binlog事务提交刷盘

server-id=${num}  #PXC集群中MySQL实例的唯一ID，不能重复，必须是数字

# Path to Galera library
wsrep_provider=/usr/lib64/libgalera_smm.so

# Cluster connection URL contains the IPs of node#1, node#2 and node#3
wsrep_cluster_address=gcomm://${master},${slave1},${slave2}

# Node 1 address
wsrep_node_address=${IP_ADDRESS} #当前节点的IP

# SST method
wsrep_sst_method=xtrabackup-v2 #同步方法（mysqldump、rsync、xtrabackup）

# Cluster name
wsrep_cluster_name=pxc_cluster #PXC集群的名称

# Authentication for SST method
wsrep_sst_auth="sstuser:s3cret" #同步使用的帐户

pxc_strict_mode=DISABLED #同步严厉模式(ENFORCING)

EOF

sed -i '/^wsrep_cluster_address=gcomm/awsrep_node_name=pxc1' /etc/my.cnf

systemctl start mysql@bootstrap.service
#echo "临时密码如下:"
tmppasswd=`grep 'temporary password' /var/log/mysqld.log | awk -F'@' '{print $2}' | awk -F':' '{print $2}' | awk -F' ' '{print $1}'`

echo "请连接数据库执行以下命令:"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${passwd}';"
echo "grant all privileges  on *.* to root@'%' identified by \"${passwd}\";"
echo "数据库的密码为[${tmppasswd}]"
sleep 2 
mysql -uroot -p 


sleep 2
mysql -uroot -p${passwd} -e "CREATE USER 'sstuser'@'localhost' IDENTIFIED BY 's3cret';" -e "GRANT RELOAD,LOCK TABLES,PROCESS,REPLICATION CLIENT ON *.* TO ' sstuser' @'localhost';" -e "flush privileges;" 



        elif [[ ${choice} == "2" ]];then
            echo "选择了slave1"
            
            
cat <<EOF > /etc/my.cnf 
#
# The Percona XtraDB Cluster 5.7 configuration file.
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#   Please make any edits and changes to the appropriate sectional files
#   included below.
#
!includedir /etc/my.cnf.d/
!includedir /etc/percona-xtradb-cluster.conf.d/

[mysqld]
federated
basedir=/data/mysqldata/mysql
datadir=/data/mysqldata/mysql
user=mysql

slow_query_log=1
binlog_format=ROW  #基于ROW复制（安全可靠）
binlog_cache_size = 2M
max_binlog_size=256M
long_query_time =2
log-queries-not-using-indexes=0
back_log=2048     #设置会话请求缓存个数
sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO,STRICT_ALL_TABLES
lower_case_table_names=1
transaction_isolation=READ-COMMITTED

default_storage_engine=innodb #默认引擎
innodb_autoinc_lock_mode=2  #主键自增长不锁表
innodb_flush_method=O_DIRECT #设置innodb数据文件及redo log的打开、刷写模式
innodb_buffer_pool_size=18G  #设置buffer pool size,一般为服务器内存60%
innodb_buffer_pool_instances=16 #设置buffer pool instance个数，提高并发能力
innodb_max_dirty_pages_pct=90
innodb_log_buffer_size=12M #设置log buffer size大小
innodb_log_file_size=512M #设置logfile大小
innodb_log_files_in_group=4 #设置logfile组个数
innodb_autoextend_increment=128
innodb_flush_log_at_trx_commit=1 #每次事务提交时Percona都会把log buffer的数据写入log file，并且flush（刷到磁盘）中去
innodb_open_files=4000 #设置最大打开表个数

max_allowed_packet=500M
connect_timeout=300


# connection limit has been reached.
max_connections=2000 #设置最大连接数
max_connect_errors=1200
open_files_limit=65535
table_open_cache = 600
table_definition_cache=600
performance_schema_max_table_instances=1024
tmp_table_size = 1024M
thread_cache_size = 256


# Set the query cache.
query_cache_size = 1G
query_cache_type = ON
query_cache_limit= 4M

max_heap_table_size= 1024M
max_allowed_packet = 32M
max_heap_table_size = 8M

# buffer size
key_buffer_size = 1024M
read_buffer_size = 4M
sort_buffer_size = 4M
join_buffer_size = 4M
read_rnd_buffer_size=4M
sync_binlog=1 #设置每次sync_binlog事务提交刷盘

server-id=${num}  #PXC集群中MySQL实例的唯一ID，不能重复，必须是数字

# Path to Galera library
wsrep_provider=/usr/lib64/libgalera_smm.so

# Cluster connection URL contains the IPs of node#1, node#2 and node#3
wsrep_cluster_address=gcomm://${master},${slave1},${slave2}

# Node 1 address
wsrep_node_address=${IP_ADDRESS} #当前节点的IP

# SST method
wsrep_sst_method=xtrabackup-v2 #同步方法（mysqldump、rsync、xtrabackup）

# Cluster name
wsrep_cluster_name=pxc_cluster #PXC集群的名称

# Authentication for SST method
wsrep_sst_auth="sstuser:s3cret" #同步使用的帐户

pxc_strict_mode=DISABLED #同步严厉模式(ENFORCING)

EOF


sed -i '/^wsrep_cluster_address=gcomm/awsrep_node_name=pxc2' /etc/my.cnf

sleep 5 
systemctl start mysqld

        elif [[ ${choice} == "3" ]];then
            echo "选择了slave2"

cat <<EOF > /etc/my.cnf 
#
# The Percona XtraDB Cluster 5.7 configuration file.
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#   Please make any edits and changes to the appropriate sectional files
#   included below.
#
!includedir /etc/my.cnf.d/
!includedir /etc/percona-xtradb-cluster.conf.d/

[mysqld]
federated
basedir=/data/mysqldata/mysql
datadir=/data/mysqldata/mysql
user=mysql

slow_query_log=1
binlog_format=ROW  #基于ROW复制（安全可靠）
binlog_cache_size = 2M
max_binlog_size=256M
long_query_time =2
log-queries-not-using-indexes=0
back_log=2048     #设置会话请求缓存个数
sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_AUTO_VALUE_ON_ZERO,STRICT_ALL_TABLES
lower_case_table_names=1
transaction_isolation=READ-COMMITTED

default_storage_engine=innodb #默认引擎
innodb_autoinc_lock_mode=2  #主键自增长不锁表
innodb_flush_method=O_DIRECT #设置innodb数据文件及redo log的打开、刷写模式
innodb_buffer_pool_size=18G  #设置buffer pool size,一般为服务器内存60%
innodb_buffer_pool_instances=16 #设置buffer pool instance个数，提高并发能力
innodb_max_dirty_pages_pct=90
innodb_log_buffer_size=12M #设置log buffer size大小
innodb_log_file_size=512M #设置logfile大小
innodb_log_files_in_group=4 #设置logfile组个数
innodb_autoextend_increment=128
innodb_flush_log_at_trx_commit=1 #每次事务提交时Percona都会把log buffer的数据写入log file，并且flush（刷到磁盘）中去
innodb_open_files=4000 #设置最大打开表个数

max_allowed_packet=500M
connect_timeout=300


# connection limit has been reached.
max_connections=2000 #设置最大连接数
max_connect_errors=1200
open_files_limit=65535
table_open_cache = 600
table_definition_cache=600
performance_schema_max_table_instances=1024
tmp_table_size = 1024M
thread_cache_size = 256


# Set the query cache.
query_cache_size = 1G
query_cache_type = ON
query_cache_limit= 4M

max_heap_table_size= 1024M
max_allowed_packet = 32M
max_heap_table_size = 8M

# buffer size
key_buffer_size = 1024M
read_buffer_size = 4M
sort_buffer_size = 4M
join_buffer_size = 4M
read_rnd_buffer_size=4M
sync_binlog=1 #设置每次sync_binlog事务提交刷盘

server-id=${num}  #PXC集群中MySQL实例的唯一ID，不能重复，必须是数字

# Path to Galera library
wsrep_provider=/usr/lib64/libgalera_smm.so

# Cluster connection URL contains the IPs of node#1, node#2 and node#3
wsrep_cluster_address=gcomm://${master},${slave1},${slave2}

# Node 1 address
wsrep_node_address=${IP_ADDRESS} #当前节点的IP

# SST method
wsrep_sst_method=xtrabackup-v2 #同步方法（mysqldump、rsync、xtrabackup）

# Cluster name
wsrep_cluster_name=pxc_cluster #PXC集群的名称

# Authentication for SST method
wsrep_sst_auth="sstuser:s3cret" #同步使用的帐户

pxc_strict_mode=DISABLED #同步严厉模式(ENFORCING)

EOF

sed -i '/^wsrep_cluster_address=gcomm/awsrep_node_name=pxc3' /etc/my.cnf
sleep 5 
systemctl start mysqld

        else
            echo "非法输入，请重新输入"
            choice
        fi 
}

choice 

echo "============================ 集群状态如下 ====================================="

mysql -uroot -p${passwd} -e "show status like 'wsrep%';"
