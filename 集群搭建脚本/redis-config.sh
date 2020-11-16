#!/usr/bin/env bash
CLUSTER_IP_1="10.10.1.160"
CLUSTER_IP_2="10.10.1.170"
CLUSTER_IP_3="10.10.1.180"
PORT_1="6379"
PORT_2="6380"
PORT_3="6381"
echo -e "\033[1;31m  此脚本需要在redis集群之外的Linux上执行 \033[0m"
echo "安装redis(centos)"
sudo yum -y install redis
#sudo apt-get install redis-tools
echo "启动redis"
systemctl start redis
echo "查看redis服务运行状态"
systemctl status redis
echo "设置开机自启动"
systemctl enable redis


echo -e "\033[1;32m  1.登录其中一个节点并且将九个节点分别加入集群 \033[0m"
ip_pre="10.10.1."
ip_start="160"
ip_end="180"
port_start="6379"
port_end="6381"
for ip_address in `seq ${ip_start} 10 ${ip_end}`
do
    for port in `seq ${port_start} ${port_end}`
    do
        redis-cli -c -h ${CLUSTER_IP_1} -p ${PORT_1} cluster meet ${ip_pre}${ip_address} ${port}
    done
done
echo "查看节点情况"
redis-cli -c -h ${CLUSTER_IP_1} -p ${PORT_1} cluster nodes

echo -e "\033[1;32m  2.分配槽 \033[0m"
echo "第一个master:${CLUSTER_IP_1} -p ${PORT_1}"
start=0
end=5461
for slot in `seq ${start} ${end}`
do
    echo "slot:${slot}"
    redis-cli -c -h ${CLUSTER_IP_1} -p ${PORT_1} cluster addslots ${slot}
done


echo "第二个master:${CLUSTER_IP_2} -p ${PORT_1}"
start=5461
end=10922
for slot in `seq ${start} ${end}`
do
    echo "slot:${slot}"
    redis-cli -c -h ${CLUSTER_IP_2} -p ${PORT_1} cluster addslots ${slot}
done

echo "第三个master:${CLUSTER_IP_3} -p ${PORT_1}"
start=10923
end=16383
for slot in `seq ${start} ${end}`
do
    echo "slot:${slot}"
    redis-cli -c -h ${CLUSTER_IP_3} -p ${PORT_1} cluster addslots ${slot}
done

echo -e "\033[1;32m  3.设置从节点 \033[0m"
ip_pre="10.10.1."
ip_start="160"
ip_end="180"
port_start="6380"
port_end="6381"
for ip_address in `seq ${ip_start} 10 ${ip_end} `
do
    for port in `seq ${port_start} ${port_end}`
    do
        #master节点的node_id
        node_id=$(redis-cli -c -h ${ip_pre}${ip_address} -p 6379 cluster nodes | grep ${ip_pre}${ip_address}:6379 | awk '{print $1}')
        redis-cli -c -h ${ip_pre}${ip_address} -p ${port} cluster replicate ${node_id}
    done
done
echo "查看集群节点状态"
redis-cli -c -h ${CLUSTER_IP_1} -p ${PORT_1} cluster nodes
echo "redis集群部署完毕"
exit

