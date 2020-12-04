#!/usr/bin/env bash 
#获取本机ip地址
IP_ADDRESS=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | awk -F " " '{print $2}' | grep -v 172 | grep -v 32 | awk -F"/" '{print $1}')
DIR="/home/redis-cluster"
echo -e "\033[1;31m  此脚本需在每个redis节点上执行 \033[0m"
echo "创建目录${DIR}"
mkdir ${DIR}

echo -e "\033[1;32m  1.开始生成redis-cluster.tmpl文件 \033[0m"
cat <<EOF >${DIR}/redis-cluster.tmpl
port \${PORT}
protected-mode no
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
cluster-announce-ip ${IP_ADDRESS}
cluster-announce-port \${PORT}
cluster-announce-bus-port 1\${PORT}
appendonly yes
EOF
echo "文件生成完毕"


#echo -e "\033[1;32m  2.创建自定义network \033[0m"
#docker network create redis-net


echo -e "\033[1;32m  3.在/home/redis-cluster下生成conf和data目标，并生成配置信息 \033[0m"
cd ${DIR}
for port in `seq 6379 6381`; do \
  mkdir -p ./${port}/conf  \
  && PORT=${port} envsubst < ./redis-cluster.tmpl > ./${port}/conf/redis.conf \
  && mkdir -p ./${port}/data; \
done


echo -e "\033[1;32m  4.创建3个redis容器 \033[0m"
#echo -e "\033[1;32m  获取redis镜像 \033[0m"
#docker pull redis:latest
echo -e "\033[1;32m  根据端口号生成redis容器并启动 \033[0m"
for port in `seq 6379 6381`; do \
  docker run -d -ti -p ${port}:${port} -p 1${port}:1${port} \
  -v ${DIR}/${port}/conf/redis.conf:/usr/local/etc/redis/redis.conf \
  -v ${DIR}/${port}/data:/data \
  --restart always --name redis-${port} --net host  \
  --sysctl net.core.somaxconn=1024 redis redis-server /usr/local/etc/redis/redis.conf; \
done
exit
