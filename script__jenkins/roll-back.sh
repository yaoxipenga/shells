#!/bin/bash
#--------------------------------脚本变量设置--------------------------------
#获取本机ip地址
ip_address=`ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | cut -d ' ' -f2 | grep -v 172 | cut -d '/' -f1 | head -1`
#服务名数组
service_name_array=(`head -1 /root/service-config.txt`)
#服务映射端口号数组
service_port_array=(`tail -1 /root/service-config.txt`)
#服务个数
service_num=${#service_port_array[@]}
#脚本运行环境(test代表测试环境，dev代表开发环境，不跟参数默认测试环境)
script_env=${1:-"test"}

cat /home/mect/script/banner.txt
echo "********************** 当前本机IP地址为：${ip_address};部署环境为：${script_env} **********************"

cd /home/mect-backup
# 获取最后一个备份文件夹(最新备份文件夹)
backup_dir=$(ls | tail -1)
echo "--------------------------------最新备份的日期文件夹为:mect-backup--------------------------------" #输出最新创建的备份文件夹
echo "当前服务器需回滚的服务有${service_num}个，分别是："
for ((i=1;i<${service_num}+1;i++))
{
  echo ${i}.${service_name_array[i-1]}:${service_port_array[i-1]};
  echo "1.暂停当前Docker容器:mect-${service_name_array[i-1]}"
  docker stop mect-${service_name_array[i-1]}
  echo "2.删除待替换的jar包:/home/mect/resource/${service_name_array[i-1]}-0.0.1-SNAPSHOT.jar"
  rm -f /home/mect/resource/${service_name_array[i-1]}-0.0.1-SNAPSHOT.jar
  echo "3.开始复制jar包副本到指定文件夹中:mect-backup/mect/resource/${service_name_array[i-1]}-0.0.1-SNAPSHOT.jar ---> /home/mect/resource"
  cp  /home/mect-backup/mect/resource/${service_name_array[i-1]}-0.0.1-SNAPSHOT.jar  /home/mect/resource
  echo "4.重新启动Docker容器:mect-${service_name_array[i-1]}"
  docker start mect-${service_name_array[i-1]}
}
echo "回滚完毕"
echo "查看所有Docker容器状态"
docker ps
exit