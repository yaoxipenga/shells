#!/usr/bin/bash 
function choice(){
        echo -n "请选择安装基础服务的类型(1.emqx;2.mongodb;3.redis;4.fastdfs;5.mysql;6.rabbitmq;7.nginx;8.lvs_keepalived_waiwang;9.lvs_keepalived_neiwang):"
        read choice
        if [[ ${choice} == "1" ]];then
            echo "选择了emqx"
            echo "emq1节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep emqx | grep emqx_emq1| awk -F':' '{print $2}'` /usr/bin/sh /root/shells/emq_cluster_install.sh
            echo "emq2节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep emqx | grep emqx_emq2| awk -F':' '{print $2}'` /usr/bin/sh /root/shells/emq_cluster_install.sh
            echo "emq3节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep emqx | grep emqx_emq3| awk -F':' '{print $2}'` /usr/bin/sh /root/shells/emq_cluster_install.sh
        
        elif [[ ${choice} == "2" ]];then
            echo "选择了mongodb"
            echo "master节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep mongodb | grep mongodb_master | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/MongoDB_cluster.sh
            echo "slave节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep mongodb | grep mongodb_slave | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/MongoDB_cluster.sh
            echo "arbite节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep mongodb | grep mongodb_arbite | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/MongoDB_cluster.sh
 
        elif [[ ${choice} == "3" ]];then
            echo "选择了redis"
            echo "redis1节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep redis | grep redis_redis1 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/redis-cluster.sh
            echo "redis2节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep redis | grep redis_redis2 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/redis-cluster.sh
            echo "redis3节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep redis | grep redis_redis3 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/redis-cluster.sh
            sleep 2
            echo "redis-config.sh将在本机执行"
            /usr/bin/sh /root/shells/redis-config.sh
      
        elif [[ ${choice} == "4" ]];then
            echo "选择了fastdfs"
            echo "fastdfs_tracker节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker1 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/fastdfs_tracker.sh
            /usr/bin/ssh `cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker2 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/fastdfs_tracker.sh
            echo "fastdfs_group1节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep fastdfs_group1 | grep fastdfs_group1_1 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/fastdfs_group1.sh
            /usr/bin/ssh `cat /root/shells/ip.txt | grep fastdfs_group1 | grep fastdfs_group1_2 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/fastdfs_group1.sh
            echo "fastdfs_group2节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep fastdfs_group2 | grep fastdfs_group2_1 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/fastdfs_group2.sh
            /usr/bin/ssh `cat /root/shells/ip.txt | grep fastdfs_group2 | grep fastdfs_group2_2 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/fastdfs_group2.sh
      
        elif [[ ${choice} == "5" ]];then
            echo "选择了mysql"
            echo "master节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep mysql_pxc | grep mysql_pxc1 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/mysql_pxc_install.sh 
            sleep 5
            /usr/bin/ssh `cat /root/shells/ip.txt | grep mysql_pxc | grep mysql_pxc1 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/var.sh
            echo "slave1节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep mysql_pxc | grep mysql_pxc2 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/mysql_pxc_install.sh
            echo "slave2节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep mysql_pxc | grep mysql_pxc3 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/mysql_pxc_install.sh

        elif [[ ${choice} == "6" ]];then
            echo "选择了rabbitmq"
            echo "master节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq1 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/rabbitmq_cluster_install.sh
            echo "slave02节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq2 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/rabbitmq_cluster_install.sh
            echo "slave03节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq3 | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/rabbitmq_cluster_install.sh

        elif [[ ${choice} == "7" ]];then
            echo "开始部署nginx集群(nginx主备)"
            echo "master节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep nginx | grep nginx_master | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/nginx_config.sh
            echo "backup节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep nginx | grep nginx_backup | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/nginx_config.sh

        elif [[ ${choice} == "8" ]];then
            echo "开始部署lvs_keepalived_waiwang集群(lvs_keepalived主备)"
            echo "master节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_waiwang1  | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/lvs_keepalived_waiwang.sh
            echo "backup节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_waiwang2  | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/lvs_keepalived_waiwang.sh

            #/usr/bin/ssh `cat /root/shells/ip.txt | grep nginx | grep nginx_master | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/lvs_dr_rs_waiwang.sh
            #/usr/bin/ssh `cat /root/shells/ip.txt | grep nginx | grep nginx_backup | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/lvs_dr_rs_waiwang.sh

        
        elif [[ ${choice} == "9" ]];then
            echo "开始部署lvs_keepalived_neiwang集群(lvs_keepalived主备)"
            echo "master节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_neiwang1  | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/lvs_keepalived_neiwang.sh
            echo "backup节点执行操作:"
            /usr/bin/ssh `cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_neiwang2  | awk -F':' '{print $2}'` /usr/bin/sh /root/shells/lvs_keepalived_neiwang.sh


	fi
        
        
} 
choice 

