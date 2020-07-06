#!/bin/bash
#获取本机ip地址
ip_address=`ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | grep -v 172 | cut -d '/' -f1 | head -1`
#服务名
# SERVICE_NAME=${1:-"eureka-server admin-server"}
#服务名数组
service_name_array=(`head -1 /root/service-config.txt`)
#服务映射端口号
# SERVICE_PORT=${2:-"8761 5000"}
#服务映射端口号数组
service_port_array=(`tail -1 /root/service-config.txt`)
#服务个数
service_num=${#service_port_array[@]}
#脚本运行环境(test代表测试环境，dev代表开发环境，不跟参数默认测试环境)
script_env=${1:-"test"}

echo "当前服务器部署服务有${service_num}个，分别是："
for ((i=1;i<${service_num}+1;i++))
{
  echo ${i}.${service_name_array[i-1]}:${service_port_array[i-1]};
  docker stop mect-${service_name_array[i-1]}
  docker rm mect-${service_name_array[i-1]}
}
cd /home/mect/config
if [ -f docker-compose.yml ];then
  echo "检测到docker-compose.yml已存在，删除之"
  rm -f docker-compose.yml
fi
#测试环境
if [ ${script_env} == "test" ];then
# vi docker-compose.yml
echo "开始动态生成docker-compose.yml"
echo "version: '3'" >> docker-compose.yml
echo "services:" >> docker-compose.yml
for ((i=0;i<${service_num};i++))
{
  echo "  ${service_name_array[i]}:                             " >> docker-compose.yml
  echo "    image: java:8                                       " >> docker-compose.yml
  echo "    restart: always                                     " >> docker-compose.yml
  echo "    container_name: mect-${service_name_array[i]}       " >> docker-compose.yml
  echo "    environment:                                        " >> docker-compose.yml
  echo "    - TZ=Asia/Shanghai                                  " >> docker-compose.yml
  echo "    ports:                                              " >> docker-compose.yml
  echo "    - ${service_port_array[i]}:${service_port_array[i]} " >> docker-compose.yml
  echo "    volumes:                                            " >> docker-compose.yml
  echo "    - /home/mect/resource:/home/mect/resource:rw        " >> docker-compose.yml
  echo "    - /home/mect/log:/home/mect/log:rw                  " >> docker-compose.yml
  echo "    - /home/mect/rules:/home/mect/rules:rw              " >> docker-compose.yml
  echo "    logging:                                            " >> docker-compose.yml
  echo "      driver: json-file                                 " >> docker-compose.yml
  echo "      options:                                          " >> docker-compose.yml
  echo "        max-size: 5m                                    " >> docker-compose.yml
  echo "    command: java -Djava.security.egd=file:/dev/./urandom -jar -Xms1024m -Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/mect/resource/${service_name_array[i]}.tdump /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar --spring.profiles.active=test --eureka.instance.ip-address=${ip_address} --spring.cloud.config.uri=http://192.168.4.41:8777" >> docker-compose.yml
  echo "    network_mode: host                                  " >> docker-compose.yml
  echo -e "\n" >> docker-compose.yml
}
#开发环境
elif [ ${script_env} == "dev" ];then
# vi docker-compose.yml
echo "开始动态生成docker-compose.yml"
echo "version: '3'" >> docker-compose.yml
echo "services:" >> docker-compose.yml
for ((i=0;i<${service_num};i++))
{
  echo "  ${service_name_array[i]}:                             " >> docker-compose.yml
  echo "    image: java:8                                       " >> docker-compose.yml
  echo "    restart: always                                     " >> docker-compose.yml
  echo "    container_name: mect-${service_name_array[i]}       " >> docker-compose.yml
  echo "    environment:                                        " >> docker-compose.yml
  echo "    - TZ=Asia/Shanghai                                  " >> docker-compose.yml
  echo "    ports:                                              " >> docker-compose.yml
  echo "    - ${service_port_array[i]}:${service_port_array[i]} " >> docker-compose.yml
  echo "    volumes:                                            " >> docker-compose.yml
  echo "    - /home/mect/resource:/home/mect/resource:rw        " >> docker-compose.yml
  echo "    - /home/mect/log:/home/mect/log:rw                  " >> docker-compose.yml
  echo "    - /home/mect/rules:/home/mect/rules:rw              " >> docker-compose.yml
  echo "    logging:                                            " >> docker-compose.yml
  echo "      driver: json-file                                 " >> docker-compose.yml
  echo "      options:                                          " >> docker-compose.yml
  echo "        max-size: 5m                                    " >> docker-compose.yml
  echo "    command: java -Djava.security.egd=file:/dev/./urandom -jar -Xms1024m -Xmx2048m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/mect/resource/${service_name_array[i]}.tdump /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar --spring.profiles.active=dev --eureka.instance.ip-address=${ip_address} --spring.cloud.config.uri=http://192.168.81.21:8777" >> docker-compose.yml
  echo "    network_mode: host                                  " >> docker-compose.yml
  echo -e "\n" >> docker-compose.yml
}
#线上环境
elif [ ${script_env} == "on-line" ];then
# vi docker-compose.yml
echo "开始动态生成docker-compose.yml"
echo "version: '3'" >> docker-compose.yml
echo "services:" >> docker-compose.yml
for ((i=0;i<${service_num};i++))
{
  echo "  ${service_name_array[i]}:                             " >> docker-compose.yml
  echo "    image: java:8                                       " >> docker-compose.yml
  echo "    restart: always                                     " >> docker-compose.yml
  echo "    container_name: mect-${service_name_array[i]}       " >> docker-compose.yml
  echo "    environment:                                        " >> docker-compose.yml
  echo "    - TZ=Asia/Shanghai                                  " >> docker-compose.yml
  echo "    ports:                                              " >> docker-compose.yml
  echo "    - ${service_port_array[i]}:${service_port_array[i]} " >> docker-compose.yml
  echo "    volumes:                                            " >> docker-compose.yml
  echo "    - /home/mect/resource:/home/mect/resource:rw        " >> docker-compose.yml
  echo "    - /home/mect/log:/home/mect/log:rw                  " >> docker-compose.yml
  echo "    - /home/mect/rules:/home/mect/rules:rw              " >> docker-compose.yml
  echo "    logging:                                            " >> docker-compose.yml
  echo "      driver: json-file                                 " >> docker-compose.yml
  echo "      options:                                          " >> docker-compose.yml
  echo "        max-size: 5m                                    " >> docker-compose.yml
  echo "    command: java -Djava.security.egd=file:/dev/./urandom -jar -Xms2048m -Xmx4096m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/mect/resource/${service_name_array[i]}.tdump /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar --spring.profiles.active=online --eureka.instance.ip-address=${ip_address} --spring.cloud.config.uri=http://192.168.4.11:8777" >> docker-compose.yml
  echo "    network_mode: host                                  " >> docker-compose.yml
  echo -e "\n" >> docker-compose.yml
}
#研发环境
elif [ ${script_env} == "rd" ];then
# vi docker-compose.yml
echo "开始动态生成docker-compose.yml"
echo "version: '3'" >> docker-compose.yml
echo "services:" >> docker-compose.yml
for ((i=0;i<${service_num};i++))
{
  echo "  ${service_name_array[i]}:                             " >> docker-compose.yml
  echo "    image: java:8                                       " >> docker-compose.yml
  echo "    restart: always                                     " >> docker-compose.yml
  echo "    container_name: mect-${service_name_array[i]}       " >> docker-compose.yml
  echo "    environment:                                        " >> docker-compose.yml
  echo "    - TZ=Asia/Shanghai                                  " >> docker-compose.yml
  echo "    ports:                                              " >> docker-compose.yml
  echo "    - ${service_port_array[i]}:${service_port_array[i]} " >> docker-compose.yml
  echo "    volumes:                                            " >> docker-compose.yml
  echo "    - /home/mect/resource:/home/mect/resource:rw        " >> docker-compose.yml
  echo "    - /home/mect/log:/home/mect/log:rw                  " >> docker-compose.yml
  echo "    - /home/mect/rules:/home/mect/rules:rw              " >> docker-compose.yml
  echo "    logging:                                            " >> docker-compose.yml
  echo "      driver: json-file                                 " >> docker-compose.yml
  echo "      options:                                          " >> docker-compose.yml
  echo "        max-size: 5m                                    " >> docker-compose.yml
  echo "    command: java -Djava.security.egd=file:/dev/./urandom -jar -Xms1024m -Xmx2048m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/home/mect/resource/${service_name_array[i]}.tdump /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar --spring.profiles.active=rd --eureka.instance.ip-address=${ip_address} --spring.cloud.config.uri=http://192.168.4.45:8777" >> docker-compose.yml
  echo "    network_mode: host                                  " >> docker-compose.yml
  echo -e "\n" >> docker-compose.yml
}
fi
echo "docker-compose.yml写入完成"
exit
