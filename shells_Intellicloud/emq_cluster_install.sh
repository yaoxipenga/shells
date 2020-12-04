#!/usr/bin/bash 
# 获取emqx的安装包
mkdir -p /data/emqx_cluster
cd /data/emqx_cluster
path=`pwd`
wget https://www.emqx.io/cn/downloads/broker/v4.2.2/emqx-centos7-4.2.2-x86_64.rpm

rpm -ivh  $path/emqx-centos7-4.2.2-x86_64.rpm

emqx start

emqx_ctl status

IP_ADDRESS=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | awk -F " " '{print $2}' | grep -v 172 | grep -v 32 | awk -F"/" '{print $1}')

choice=`cat /root/shells/ip.txt | grep domain | head -1 | awk -F'=' '{print $2}'`

online_domain="online.medciot.com"
test_domain="test.medciot.com"
dev_domain="dev.medciot.com"
szonline_domain="szonline.medciot.com"

#function choice(){
#    echo -n "请选择平台(1.online;2.test;3.dev;4.szonline):"
#    read choice
    if [[ ${choice} == "1" ]];then
        echo "选择了online"
        domain=${online_domain}
    elif [[ ${choice}  == "2" ]];then
        echo "选择了test"
        domain=${test_domain}
    elif [[ ${choice} == "3" ]];then
        echo "选择了dev"
        domain=${dev_domain}
    elif [[ ${choice} == "4" ]];then
        echo "选择了szonline"
        domain=${szonline_domain}
    else
        echo "非法输入，请重新输入"
    fi
#}
#choice

#echo -n "请输入emq1所在的IP地址:"
#read emq_ip_address1
emq_ip_address1=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq1| awk -F':' '{print $2}'`
#echo -n "请输入emq2所在的IP地址:"
#read emq_ip_address2
emq_ip_address2=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq2| awk -F':' '{print $2}'`
#echo -n "请输入emq3所在的IP地址:"
#read emq_ip_address3
emq_ip_address3=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq3| awk -F':' '{print $2}'`

sed -i "/^node.name = emqx@/cnode.name = emqx@${IP_ADDRESS}" /etc/emqx/emqx.conf

sed -i "/^listener.tcp.external = /clistener.tcp.external = 0.0.0.0:1882" /etc/emqx/emqx.conf

sed -i "/^cluster.discovery = /ccluster.discovery = static" /etc/emqx/emqx.conf 

sed -i "/^## cluster.static.seeds = /ccluster.static.seeds = emqx@$emq_ip_address1,emqx@$emq_ip_address2,emqx@$emq_ip_address3" /etc/emqx/emqx.conf

sed -i "/^## node.async_threads/cnode.async_threads = 32" /etc/emqx/emqx.conf

sed -i "/^## node.process_limit = /cnode.process_limit = 2097152" /etc/emqx/emqx.conf

sed -i "/node.max_ports = /cnode.max_ports =1048576" /etc/emqx/emqx.conf 

sed -i "/node.dist_buffer_size = /cnode.dist_buffer_size = 8MB" /etc/emqx/emqx.conf 

sed -i "/node.max_ets_tables = /cnode.max_ets_tables = 262144" /etc/emqx/emqx.conf

sed -i "/node.fullsweep_after = /cnode.fullsweep_after = 1000" /etc/emqx/emqx.conf

sed -i "/node.dist_net_ticktime = /cnode.dist_net_ticktime = 120" /etc/emqx/emqx.conf 

sed -i "/node.process_limit = /cnode.process_limit = 2097152" /etc/emqx/emqx.conf 

sed -i "/^{deny, all, subscribe, /c%%{deny, all, subscribe, \[\"\$SYS\/#\", {eq, \"#\"}\]}."  /etc/emqx/acl.conf 

sed -i "/auth.http.auth_req = /cauth.http.auth_req = http://${domain}/api/mqtt/authenticate/login" /etc/emqx/plugins/emqx_auth_http.conf

emqx restart

emqx_ctl cluster status

echo "======================= emqx配置完毕 =========================="
echo "======================= 请在浏览器输入 http://${emq_ip_address1}:18083 或者 http://${emq_ip_address2}:18083 或者 http://${emq_ip_address3}:18083 查看 ================="
