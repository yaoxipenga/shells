DIR=$(pwd)
GROUP_NAME="group1"
TRACKER_SERVER1=`cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker1 | awk -F':' '{print $2}'`
TRACKER_SERVER2=`cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker2 | awk -F':' '{print $2}'`
TRACKER_PORT="22122"
echo -e "\033[1;32m 1.获取fastdfs的docker镜像 \033[0m"
docker pull morunchang/fastdfs:latest
echo -e "\033[1;32m 3.生成storage.conf配置文件 \033[0m"
cat <<EOF >${DIR}/storage.conf
disabled=false
group_name=${GROUP_NAME}
bind_addr=
client_bind=true
port=23000
connect_timeout=30
network_timeout=60
heart_beat_interval=30
stat_report_interval=60
base_path=/data/fast_data
max_connections=256
buff_size = 256KB
accept_threads=1
work_threads=4
disk_rw_separated = true
disk_reader_threads = 1
disk_writer_threads = 1
sync_wait_msec=50
sync_interval=0
sync_start_time=00:00
sync_end_time=23:59
write_mark_file_freq=500
store_path_count=2
store_path0=/fastdfs/store_path0
store_path1=/fastdfs/store_path1
subdir_count_per_path=256
tracker_server=${TRACKER_SERVER1}:${TRACKER_PORT}
tracker_server=${TRACKER_SERVER2}:${TRACKER_PORT}
log_level=info
run_by_group=
run_by_user=
allow_hosts=*
file_distribute_path_mode=0
file_distribute_rotate_count=100
fsync_after_written_bytes=0
sync_log_buff_interval=10
sync_binlog_buff_interval=10
sync_stat_file_interval=300
thread_stack_size=512KB
upload_priority=10
if_alias_prefix=
check_file_duplicate=0
file_signature_method=hash
key_namespace=FastDFS
keep_alive=0
use_access_log = false
rotate_access_log = false
access_log_rotate_time=00:00
rotate_error_log = false
error_log_rotate_time=00:00
rotate_access_log_size = 0
rotate_error_log_size = 0
log_file_keep_days = 0
file_sync_skip_invalid_record=false
use_connection_pool = false
connection_pool_max_idle_time = 3600
http.domain_name=
http.server_port=8888
EOF
echo -e "\033[1;32m 4.生成storage.sh脚本文件 \033[0m"
cat <<EOF >${DIR}/storage.sh
sed "s/^.*tracker_server=.*$/tracker_server=$TRACKER_IP/" /etc/fdfs/storage.conf > storage.conf
sed "s/^.*group_name=.*$/group_name=$GROUP_NAME/" storage.conf > storage_.conf
cp storage_.conf /etc/fdfs/storage.conf
/data/fastdfs/storage/fdfs_storaged /usr/local/storage.conf
sed "s/^.*tracker_server=.*$/tracker_server=$TRACKER_IP/" /etc/fdfs/mod_fastdfs.conf > mod_fastdfs.conf
sed "s/^.*group_name=.*$/group_name=$GROUP_NAME/" mod_fastdfs.conf > mod_fastdfs_.conf
cp mod_fastdfs_.conf /etc/fdfs/mod_fastdfs.conf
/etc/nginx/sbin/nginx
tail -f /data/fast_data/logs/storaged.log
EOF
echo -e "\033[1;32m 5.给所有文件赋权 \033[0m"
chmod +x ${DIR}/*
echo -e "\033[1;32m 查看文件目录结构 \033[0m"
tree
echo -e "\033[1;32m 6.生成storage容器并启动 \033[0m"
docker run -itd --name storage --restart=always --net=host -v storage_data:/data/fast_data -v store_path0:/fastdfs/store_path0 -v store_path1:/fastdfs/store_path1 -v ${DIR}/storage.sh:/usr/local/storage.sh -v ${DIR}/storage.conf:/usr/local/storage.conf  morunchang/fastdfs sh /usr/local/storage.sh
echo -e "\033[1;32m 查看storage容器启动状态 \033[0m"
docker ps
echo -e "\033[1;32m fastdfs集群部署完毕 \033[0m"
exit
