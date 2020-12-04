#!/bin/bashrabbitmq_master
#获取本机ip地址
#ip_address=`ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | grep -v 172 | cut -d '/' -f1 | head -1`
ip_address=`ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | grep -v 172 | grep -v 32 | awk -F'/' '{print $1}'`
#节点num
num=`ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | grep -v 172 | grep -v 32 | awk -F'/' '{print $1}' | awk -F"." '{print $4}'`

#echo -n "请输入master节点的IP:"
#read rabbitmq_master
rabbitmq_master=`cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq1 | awk -F':' '{print $2}'`
#echo -n "请输入slave02节点的IP:"
#read rabbitmq_slave02
rabbitmq_slave02=`cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq2 | awk -F':' '{print $2}'`
#echo -n "请输入slave03节点的IP:"
#read rabbitmq_slave03
rabbitmq_slave03=`cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq3 | awk -F':' '{print $2}'`
#创建集群脚本目录
mkdir /data/rabbitmq_cluster  -p 
cd /data/rabbitmq_cluster

#function choice(){
#	echo -n "请选择节点(1.master;2.slave02;3.slave03)"
#        read choice 
        if [[ ${ip_address} == ${rabbitmq_master} ]];then 

echo "选择了master"
echo "开始动态生成docker-compose.yml"
echo "version: '3'" >> docker-compose.yml
echo "services:" >> docker-compose.yml
  echo "  rabbitmq_master:                                                      " >> docker-compose.yml 
  echo "    image: rabbitmq:3.8.8-management                                    " >> docker-compose.yml
  echo "    restart: always                                                     " >> docker-compose.yml
  echo "    ports:                                                              " >> docker-compose.yml
  echo "      - \"4369:4369\"                                                   " >> docker-compose.yml
  echo "      - \"5671:5671\"                                                   " >> docker-compose.yml
  echo "      - \"25672:25672\"                                                 " >> docker-compose.yml
  echo "      - \"5672:5672\"                                                   " >> docker-compose.yml
  echo "      - \"15672:15672\"                                                 " >> docker-compose.yml
  echo "    hostname: rabbitmq_cluster_01                                       " >> docker-compose.yml
  echo "    container_name: rabbitmq_cluster_01                                 " >> docker-compose.yml
  echo "    environment:                                                        " >> docker-compose.yml
  echo "      - RABBITMQ_ERLANG_COOKIE='mectcookie'                             " >> docker-compose.yml
  echo "      - CONTAINER_TIMEZONE=Asia/Shanghai                                " >> docker-compose.yml
  echo "    volumes:                                                            " >> docker-compose.yml
  echo "      - ./rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf                     " >> docker-compose.yml
  echo "      - ./rabbitmq_config.sh:/usr/local/bin/rabbitmq_config.sh          " >> docker-compose.yml
  echo "      - /home/mect/rabbitmqcluster/data/rabbitmq${num}:/var/lib/rabbitmq" >> docker-compose.yml
  echo "    network_mode: host                                                  " >> docker-compose.yml
  echo "    extra_hosts:                                                        " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_01:${rabbitmq_master}\"                      " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_02:${rabbitmq_slave02}\"                     " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_03:${rabbitmq_slave03}\"                     " >> docker-compose.yml

cat <<EOF > rabbitmq.conf
tcp_listen_options.backlog = 128
tcp_listen_options.nodelay = true
tcp_listen_options.linger.on = true
tcp_listen_options.linger.timeout = 0
tcp_listen_options.sndbuf = 196608
tcp_listen_options.recbuf = 196608
loopback_users.guest = false
loopback_users.icc-dev = false
listeners.tcp.default = 5672
management.tcp.port = 15672
disk_free_limit.absolute = 1GB
disk_free_limit.relative=1.0
vm_memory_high_watermark.relative = 0.66
EOF

cat <<EOF > rabbitmq_config.sh
#!/usr/bin/env bash

rabbitmq-plugins enable rabbitmq_management
rabbitmq-plugins enable rabbitmq_stomp

rabbitmqctl add_vhost /icc-websocket
rabbitmqctl add_vhost /device-status
rabbitmqctl add_user icc-dev icc-dev
rabbitmqctl set_user_tags icc-dev administrator
rabbitmqctl set_permissions -p "/icc-websocket" icc-dev '.*' '.*' '.*'
rabbitmqctl set_permissions -p "/device-status" icc-dev '.*' '.*' '.*'

rabbitmqctl add_user mect mect
rabbitmqctl set_user_tags mect administrator
rabbitmqctl set_permissions -p "/device-status" mect '.*' '.*' '.*'

rabbitmqctl list_users
EOF

docker-compose -f docker-compose.yml up -d
echo "=============================注:请执行以下命令启动容器以及后续的配置====================================="
echo "docker exec -it `docker ps -a | grep rabbitmq:3.8.8-management  | awk -F" " '{print $1}'` sh /usr/local/bin/rabbitmq_config.sh"

sleep 10


        elif [[ ${ip_address} == ${rabbitmq_slave02} ]];then
echo "选择了slave02"
echo "开始动态生成docker-compose.yml"
echo "version: '3'" >> docker-compose.yml
echo "services:" >> docker-compose.yml
  echo "  rabbitmq_slave02:" >> docker-compose.yml
  echo "    image: rabbitmq:3.8.8-management                                    " >> docker-compose.yml
  echo "    restart: always                                                     " >> docker-compose.yml
  echo "    ports:                                                              " >> docker-compose.yml
  echo "      - \"4369:4369\"                                                   " >> docker-compose.yml
  echo "      - \"5671:5671\"                                                   " >> docker-compose.yml
  echo "      - \"25672:25672\"                                                 " >> docker-compose.yml
  echo "      - \"5672:5672\"                                                   " >> docker-compose.yml
  echo "      - \"15672:15672\"                                                 " >> docker-compose.yml
  echo "    hostname: rabbitmq_cluster_02                                       " >> docker-compose.yml
  echo "    container_name: rabbitmq_cluster_02                                 " >> docker-compose.yml
  echo "    environment:                                                        " >> docker-compose.yml
  echo "      - RABBITMQ_ERLANG_COOKIE='mectcookie'                             " >> docker-compose.yml
  echo "      - RABBITMQ_HOSTNAME=rabbitmq_cluster_02                           " >> docker-compose.yml
  echo "      - RABBITMQ_NODENAME=rabbit                                        " >> docker-compose.yml
  echo "      - RMQHA_RAM_NODE=true                                             " >> docker-compose.yml
  echo "      - RMQHA_MASTER_NODE=rabbit                                        " >> docker-compose.yml
  echo "      - RMQHA_MASTER_HOSTNAME=rabbitmq_cluster_01                       " >> docker-compose.yml
  echo "      - CONTAINER_TIMEZONE=Asia/Shanghai                                " >> docker-compose.yml
  echo "    volumes:                                                            " >> docker-compose.yml
  echo "      - ./rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf                     " >> docker-compose.yml
  echo "      - ./join_cluster.sh:/usr/local/bin/join_cluster.sh                " >> docker-compose.yml
  echo "      - /home/mect/rabbitmqcluster/data/rabbitmq${num}:/var/lib/rabbitmq" >> docker-compose.yml
  echo "    network_mode: host                                                  " >> docker-compose.yml
  echo "    extra_hosts:                                                        " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_01:${rabbitmq_master}\"                      " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_02:${rabbitmq_slave02}\"                     " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_03:${rabbitmq_slave03}\"                     " >> docker-compose.yml

cat <<EOF > rabbitmq.conf
tcp_listen_options.backlog = 128
tcp_listen_options.nodelay = true
tcp_listen_options.linger.on = true
tcp_listen_options.linger.timeout = 0
tcp_listen_options.sndbuf = 196608
tcp_listen_options.recbuf = 196608
loopback_users.guest = false
loopback_users.icc-dev = false
listeners.tcp.default = 5672
management.tcp.port = 15672
disk_free_limit.absolute = 1GB
disk_free_limit.relative=1.0
vm_memory_high_watermark.relative = 0.66
EOF


cat <<EOF > join_cluster.sh
#!/bin/bash
set -e

if [ -e "/root/is_not_first_time" ]; then
    exec "\$@"
else
    /usr/local/bin/docker-entrypoint.sh rabbitmq-server -detached # 先按官方入口文件启动且是后台运行

    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" stop_app # 停止应用
    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" reset
    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" join_cluster \${RMQHA_RAM_NODE:+--ram} "\$RMQHA_MASTER_NODE@\$RMQHA_MASTER_HOSTNAME" # 加入rmqha_node0集群
    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" start_app # 启动应用
    rabbitmqctl stop # 停止所有服务

    touch /root/is_not_first_time
    sleep 2s
    exec "\$@"
fi
EOF

docker-compose -f docker-compose.yml up -d
echo "=============================注:请执行以下命令启动容器以及后续的配置====================================="
echo "docker exec -it `docker ps -a | grep rabbitmq:3.8.8-management  | awk -F" " '{print $1}'` sh /usr/local/bin/join_cluster.sh"

sleep 10 

        elif [[ ${ip_address} == ${rabbitmq_slave03} ]];then
echo "选择了slave03"
echo "开始动态生成docker-compose.yml"
echo "version: '3'" >> docker-compose.yml
echo "services:" >> docker-compose.yml
  echo "  rabbitmq_slave03:" >> docker-compose.yml
  echo "    image: rabbitmq:3.8.8-management                                    " >> docker-compose.yml
  echo "    restart: always                                                     " >> docker-compose.yml
  echo "    ports:                                                              " >> docker-compose.yml
  echo "      - \"4369:4369\"                                                   " >> docker-compose.yml
  echo "      - \"5671:5671\"                                                   " >> docker-compose.yml
  echo "      - \"25672:25672\"                                                 " >> docker-compose.yml
  echo "      - \"5672:5672\"                                                   " >> docker-compose.yml
  echo "      - \"15672:15672\"                                                 " >> docker-compose.yml
  echo "    hostname: rabbitmq_cluster_03                                       " >> docker-compose.yml
  echo "    container_name: rabbitmq_cluster_03                                 " >> docker-compose.yml
  echo "    environment:                                                        " >> docker-compose.yml
  echo "      - RABBITMQ_ERLANG_COOKIE='mectcookie'                             " >> docker-compose.yml
  echo "      - RABBITMQ_HOSTNAME=rabbitmq_cluster_03                           " >> docker-compose.yml
  echo "      - RABBITMQ_NODENAME=rabbit                                        " >> docker-compose.yml
  echo "      - RMQHA_RAM_NODE=true                                             " >> docker-compose.yml
  echo "      - RMQHA_MASTER_NODE=rabbit                                        " >> docker-compose.yml
  echo "      - RMQHA_MASTER_HOSTNAME=rabbitmq_cluster_01                       " >> docker-compose.yml
  echo "      - CONTAINER_TIMEZONE=Asia/Shanghai                                " >> docker-compose.yml
  echo "    volumes:                                                            " >> docker-compose.yml
  echo "      - ./rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf                     " >> docker-compose.yml
  echo "      - ./join_cluster.sh:/usr/local/bin/join_cluster.sh                " >> docker-compose.yml
  echo "      - /home/mect/rabbitmqcluster/data/rabbitmq${num}:/var/lib/rabbitmq" >> docker-compose.yml
  echo "    network_mode: host                                                  " >> docker-compose.yml
  echo "    extra_hosts:                                                        " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_01:${rabbitmq_master}\"                      " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_02:${rabbitmq_slave02}\"                     " >> docker-compose.yml
  echo "      - \"rabbitmq_cluster_03:${rabbitmq_slave03}\"                     " >> docker-compose.yml

cat <<EOF > rabbitmq.conf
tcp_listen_options.backlog = 128
tcp_listen_options.nodelay = true
tcp_listen_options.linger.on = true
tcp_listen_options.linger.timeout = 0
tcp_listen_options.sndbuf = 196608
tcp_listen_options.recbuf = 196608
loopback_users.guest = false
loopback_users.icc-dev = false
listeners.tcp.default = 5672
management.tcp.port = 15672
disk_free_limit.absolute = 1GB
disk_free_limit.relative=1.0
vm_memory_high_watermark.relative = 0.66
EOF


cat <<EOF > join_cluster.sh
#!/bin/bash
set -e

if [ -e "/root/is_not_first_time" ]; then
    exec "\$@"
else
    /usr/local/bin/docker-entrypoint.sh rabbitmq-server -detached # 先按官方入口文件启动且是后台运行

    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" stop_app # 停止应用
    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" reset
    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" join_cluster \${RMQHA_RAM_NODE:+--ram} "\$RMQHA_MASTER_NODE@\$RMQHA_MASTER_HOSTNAME" # 加入rmqha_node0集群
    rabbitmqctl -n "\$RABBITMQ_NODENAME@\$RABBITMQ_HOSTNAME" start_app # 启动应用
    rabbitmqctl stop # 停止所有服务

    touch /root/is_not_first_time
    sleep 2s
    exec "\$@"
fi
EOF


docker-compose -f docker-compose.yml up -d
echo "=============================注:请执行以下命令启动容器以及后续的配置====================================="
echo "docker exec -it `docker ps -a | grep rabbitmq:3.8.8-management  | awk -F" " '{print $1}'` sh /usr/local/bin/join_cluster.sh"

        else
            echo "非法输入，请重新输入"
        fi 

sleep 10 



echo "=============================注:请在${rabbitmq_master},${rabbitmq_slave02},${rabbitmq_slave03} 任意节点执行配置策略====================================="
echo "docker exec -it `docker ps -a | grep rabbitmq:3.8.8-management  | awk -F" " '{print $1}'` rabbitmqctl set_policy  -p \"/device-status\" policy1 \"^\" '{\"ha-mode\":\"nodes\", \"ha-params\":[\"rabbit@rabbitmq_cluster_02\",\"rabbit@rabbitmq_cluster_03\"], \"ha-sync-mode\":\"automatic\"}'"

echo "docker exec -it `docker ps -a | grep rabbitmq:3.8.8-management  | awk -F" " '{print $1}'` rabbitmqctl set_policy  -p \"/icc-websocket\" policy1 \"^\" '{\"ha-mode\":\"nodes\", \"ha-params\":[\"rabbit@rabbitmq_cluster_02\",\"rabbit@rabbitmq_cluster_03\"], \"ha-sync-mode\":\"automatic\"}'"


echo "================================ 节点配置完毕  ======================================"
echo "================================ 请在所有节点配置完毕后登陆 ${rabbitmq_master}:15672 或者 ${rabbitmq_slave02}:15672 或者 ${rabbitmq_slave03}:15672 查看集群状态 =================================="
echo "================================ 初始用户名/密码 guest/guest ========================" 

