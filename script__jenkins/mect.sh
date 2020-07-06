
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

cat /root/tmp/script/banner.txt
echo "显示临时文件目录结构"
tree /root/tmp/
echo "********************** 当前本机IP地址为：${ip_address};部署环境为：${script_env} **********************"
#--------------------------------1.备份项目旧版本--------------------------------
echo "--------------------------------1.开始备份项目旧版本--------------------------------"
backup_date=`date "+%Y-%m-%dT%H:%M:%S"`
#判断配置文件是否为空，为空则无需备份
if [ ${service_num} == 0 ];then
    echo "检测到配置文件中无需要更新的服务,则无需备份："
else
    echo "①.开始备份文件"
    #检测mect文件夹是否存在，存在则备份，否则不作任何操作
    if [ -d /home/mect ];then
      echo "②.根据日期新建备份文件夹/home/mect-backup/${backup_date}"
      mkdir -p /home/mect-backup/"${backup_date}"/mect/{script,log,resource,rules,config}
      cp /home/mect/config/* /home/mect-backup/${backup_date}/mect/config
      cp /home/mect/rules/* /home/mect-backup/${backup_date}/mect/rules
      cp /home/mect/script/* /home/mect-backup/${backup_date}/mect/script

      for ((i=0;i<${service_num};i++))
      {
          echo "复制: /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar 到 /home/mect-backup/${backup_date}/mect/resource "
          cp -r /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar /home/mect-backup/${backup_date}/mect/resource
          echo "删除：服务 ${service_name_array[i]} --- jar包 /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar"
          rm -f /home/mect/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar

          echo "复制: /home/mect/log/${service_name_array[i]} 到 /home/mect-backup/${backup_date}/mect/log "
          cp -r /home/mect/log/${service_name_array[i]} /home/mect-backup/${backup_date}/mect/log
          echo "删除：服务 ${service_name_array[i]} --- 日志目录 /home/mect/log/${service_name_array[i]}"
          rm -rf /home/mect/log/${service_name_array[i]}
      }

      #复制/root/service-config.txt配置文件到/home/mect/config目录下
      cp /root/service-config.txt /home/mect-backup/${backup_date}/mect/config
      echo "--------------------------------1.旧项目备份完成--------------------------------"
      tree /home/mect-backup/${backup_date}
    else
        echo "③.目录不存在，无需备份"
    fi
fi

#--------------------------------2.新建目录--------------------------------
echo "--------------------------------2.开始创建Jenkins自动部署目录--------------------------------"
echo "项目目录结构为："
echo "/root/"
echo "└── tmp"
echo "/home/"
echo "├── mect-backup"
echo "└── mect"
echo "   ├── config"
echo "   ├── log"
echo "   ├── resource"
echo "   ├── rules"
echo "   └── script"

#判断配置文件是否为空，为空则无需进行任何操作
if [ ${service_num} == 0 ];then
    echo "检测到配置文件中无需要更新的服务,查看所有服务容器状态："
    docker ps
else
    echo "①.创建目录：/home/mect/{log,resource,script,config,rules}"
    mkdir -p /home/mect/{log,resource,script,config,rules}

    echo "②.清空：/home/mect/script目录下的所有文件"
    rm -rf /home/mect/script/*

    echo "③.移动：/root/tmp/script 到 /home/mect"
    mv /root/tmp/script  /home/mect

    #根据配置文件中的服务列表将所需jar包移动到/home/mect/resource下
    echo "根据配置文件中的服务列表将所需jar包移动到/home/mect/resource下"
    for ((i=0;i<${service_num};i++))
    {
        echo "移动：/root/tmp/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar 到 /home/mect/resource"
        mv /root/tmp/resource/${service_name_array[i]}-0.0.1-SNAPSHOT.jar  /home/mect/resource
        if [[ ${service_name_array[i]} == "parse-data-service" ]]; then
            echo "移动：/home/mect/script/*.drl文件 到 /home/mect/rules"
            mv /home/mect/script/*.drl  /home/mect/rules
        fi
    }

    echo "--------------------------------2.目录构建完成--------------------------------"
    tree /home/mect


    #--------------------------------3.生成docker-compose.yml--------------------------------
    echo "--------------------------------3.生成docker-compose.yml配置文件--------------------------------"
    echo "①.获取java8镜像"
    result=`docker images | grep java`
    if [[ ${result} == "" ]]; then
        echo "没有java:8镜像,开始在线获取";
        docker pull java:8
    else
        echo "有java:8镜像,无需在线获取"
    fi
    echo "②.执行脚本，生成docker-compose.yml配置文件"
    bash /home/mect/script/docker-compose.sh ${script_env}
    echo "--------------------------------3.配置文件生成成功--------------------------------"

    #--------------------------------4.构建镜像并启动容器--------------------------------
    echo "--------------------------------4.构建镜像并启动容器--------------------------------"
    cd /home/mect/config
    docker-compose up -d
    echo "--------------------------------4.构建镜像并启动容器完成--------------------------------"
    docker ps
    docker-compose ps
fi
echo "清除临时目录/root/tmp"
rm -rf /root/tmp
echo "临时目录清除完毕"

echo "--------------------------------5.开始清除老旧备份，只留下三份历史版本--------------------------------"
backup_dirs=(`ls -rt /home/mect-backup`)
#备份文件夹个数
backup_dirs_num=${#backup_dirs[@]}
if [ ${backup_dirs_num} -lt 4 ];then
    echo "" > /dev/null
else
    #删除老旧备份文件夹,只保留三个版本
    for ((i=0;i<${backup_dirs_num}-3;i++))
    {
        #遍历删除旧文件夹
        rm -rf /home/mect-backup/${backup_dirs[i]}
    }
fi
echo "--------------------------------5.清除老旧备份成功--------------------------------"
exit