#!/usr/bin/bash 
#echo "请前往  https://www.mongodb.com/try/download/community 下载centos7.0的tgz包，然后进行后续操作"
echo "下载mogodb的安装包"
wget -P /tmp/ https://downloads.mongodb.com/linux/mongodb-linux-x86_64-enterprise-rhel70-4.4.2.tgz

tar -zxvf /tmp/mongodb-linux-x86_64-enterprise-rhel70-4.4.2.tgz -C /tmp 

mv /tmp/mongodb-linux-x86_64-enterprise-rhel70-4.4.2 /usr/local/mongodb

rm -rf /tmp/mongodb-linux-x86_64-enterprise-rhel70-4.4.2.tgz

IP_ADDRESS=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g'  | awk -F' ' '{print $2}' | grep -v 32 | awk -F'/' '{print $1}' | grep -v 172.17.0.1)
echo "********************** 当前本机IP地址为：${IP_ADDRESS} 此脚本需要在每台电脑上执行 **********************"
echo "新建mongodb配置文件夹"
mkdir -p /usr/local/mongodb/{conf,data,logs}

#echo -n "请输入master节点的IP:"
#read master_ip
master_ip=`cat /root/shells/ip.txt | grep mongodb | grep mongodb_master | awk -F':' '{print $2}'`
#echo -n "请输入slave节点的IP:"
#read slave_ip
slave_ip=`cat /root/shells/ip.txt | grep mongodb | grep mongodb_slave | awk -F':' '{print $2}'`
#echo -n "请输入arbite节点的IP:"
#read arbite_ip
arbite_ip=`cat /root/shells/ip.txt | grep mongodb | grep mongodb_arbite | awk -F':' '{print $2}'`

        if [[ ${IP_ADDRESS} == ${master_ip} ]];then 
            echo "选择了master"
            touch /usr/local/mongodb/logs/master.log
            
#生成master的配置文件
cat <<EOF > /usr/local/mongodb/conf/mongodb.conf
#master配置
dbpath=/usr/local/mongodb/data
logpath=/usr/local/mongodb/logs/master.log
logappend=true
bind_ip=${master_ip}
port=27017
fork=true
replSet=test
EOF

        elif [[ ${IP_ADDRESS} == ${slave_ip} ]];then
            echo "选择了slave"
            touch /usr/local/mongodb/logs/slave.log
cat <<EOF > /usr/local/mongodb/conf/mongodb.conf
#slave配置
dbpath=/usr/local/mongodb/data
logpath=/usr/local/mongodb/logs/slave.log
logappend=true
bind_ip=${slave_ip}
port=27017
fork=true
replSet=test
EOF

        elif [[ ${IP_ADDRESS} == ${arbite_ip} ]];then
            echo "选择了arbite"
            touch /usr/local/mongodb/logs/arbite.log
cat <<EOF > /usr/local/mongodb/conf/mongodb.conf
#仲裁节点配置
dbpath=/usr/local/mongodb/data
logpath=/usr/local/mongodb/logs/arbite.log
logappend=true
bind_ip=${arbite_ip}
port=27018
fork=true
replSet=test
EOF
        else
            echo "非法输入，请重新输入"
        fi 



yum -y install net-snmp

#启动mongo
/usr/local/mongodb/bin/mongod -f /usr/local/mongodb/conf/mongodb.conf --fork 

#sleep 5

#/usr/local/mongodb/bin/mongo ${master_ip}:27017 <<EOF 
#cfg={ _id:"test", members:[ {_id:0,host:'${slave_ip}:27017',priority:2},{_id:1,host:'${master_ip}:27017',priority:1},{_id:2,host:'${arbite_ip}:27018',arbiterOnly:true}] };
#EOF

#/usr/local/mongodb/bin/mongo ${master_ip}:27017 <<EOF
#rs.initiate(cfg)
#EOF

#/usr/local/mongodb/bin/mongo ${master_ip}:27017 <<EOF
#rs.status()
#EOF

cat <<EOF >/etc/rc.d/init.d/mongod
start() {  
/usr/local/mongodb/bin/mongod  --config /usr/local/mongodb/conf/mongodb.conf
}  

stop() {  
/usr/local/mongodb/bin/mongod --config /usr/local/mongodb/conf/mongodb.conf --shutdown  
}  
case "$1" in  
start)  
start
 ;;  

stop)  
stop
 ;;  

restart)  
stop
start
 ;;  
  *)  
echo
$"Usage: $0 {start|stop|restart}"  
exit 1  
esac
EOF

chmod +x /etc/rc.d/init.d/mongod

echo -e  "请连接主节点或者从节点进行相关的配置: mongo ${master_ip}:27017 或 mongo ${slave_ip}:27017\n请输入以下几条命令进行相关配置\ncfg={ _id:\"test\", members:[ {_id:0,host:'${slave_ip}:27017',priority:2},{_id:1,host:'${master_ip}:27017',priority:1},{_id:2,host:'${arbite_ip}:27018',arbiterOnly:true}] };\nrs.initiate(cfg)\nrs.status()"

exit





