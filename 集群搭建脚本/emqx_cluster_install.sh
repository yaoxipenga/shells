#!/usr/bin/env bash 
#环境安装
# erlang下载 https://www.erlang-solutions.com/resources/download.html;https://github.com/rabbitmq/erlang-rpm/releases

echo -e "\033[1;32m 卸载erlang  \033[0m"
yum -y remove erlang
rpm -qa | grep erlang | xargs -I {} rpm -e {}
echo -e "\033[1;32m 安装socat  \033[0m"
yum -y install socat

echo -e "\033[1;32m 安装erlang \033[0m"
rpm -ivh erlang-21.3.8.1-1.el7.x86_64.rpm

IP_ADDRESS=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g' | awk -F " " '{print $2}' | grep -v 172 | grep -v 32 | awk -F"/" '{print $1}')
#复制emqx到指定目录中
cp emqx-rel.zip /usr/local/src/
#解压emqx
unzip /usr/local/src/emqx-rel.zip -d /usr/local/src/

#域名
online_domain="online.medciot.com"
test_domain="test.medciot.com"
dev_domain="dev.medciot.com"
domain=""

function choice(){
    echo -n "请选择平台(1.online;2.test;3.dev):"
    read choice
    if [[ ${choice} == "1" ]];then
        echo "选择了online"
        domain=${online_domain}
    elif [[ ${choice}  == "2" ]];then
        echo "选择了test"
        domain=${test_domain}
    elif [[ ${choice} == "3" ]];then
        echo "选择了dev"
        domain=${dev_domain}
    else
        echo "非法输入，请重新输入"
        choice
    fi
}
choice

echo -n "请输入emq1所在的IP地址:"
read emq_ip_address1
echo -n "请输入emq2所在的IP地址:"
read emq_ip_address2
echo -n "请输入emq3所在的IP地址:"
read emq_ip_address3


#修改插件配置文件，更改域名地址
sed -i "s/test.medciot.com/${domain}/g" /usr/local/src/emqx-rel/deps/emqx_plugin_template/src/emqx_plugin_template.erl
cd /usr/local/src/emqx-rel/
#重新编译，此操作会重新生成配置文件
make -C /usr/local/src/emqx-rel

sed -i "/^node.name = emqx@/cnode.name = emqx@${IP_ADDRESS}" /usr/local/src/emqx-rel/_rel/emqx/etc/emqx.conf

#修改集群的监听端口
sed -i "/^listener.tcp.external =/clistener.tcp.external = 0.0.0.0:1882" /usr/local/src/emqx-rel/_rel/emqx/etc/emqx.conf

#修改集群的发现方式
sed -i "/^cluster.discovery = /ccluster.discovery = static" /usr/local/src/emqx-rel/_rel/emqx/etc/emqx.conf

sed -i "/^## cluster.static.seeds = /ccluster.static.seeds = emqx@$emq_ip_address1,emqx@$emq_ip_address2,emqx@$emq_ip_address3" /usr/local/src/emqx-rel/_rel/emqx/etc/emqx.conf

sed -i "/^{deny, all, subscribe, /c%%{deny, all, subscribe, \[\"\$SYS\/#\", {eq, \"#\"}\]}." /usr/local/src/emqx-rel/_rel/emqx/etc/acl.conf

# 端口说明：
# nginx-1882：没有任何认证方式
# nginx-1883：单项认证
# nginx-1884：双向认证
# emq-1885：没有任何认证方式，与nginx-1882一致

# 注意：
# 若emq和nginx在同一台机器上，则nginx端口不能和emq冲突
# 无论emq和nginx在不在同一台机器上，emq只需要开启非鉴权端口即可
# 若证书重新生成，必须重启emq和nginx（nginx -s reload,这个reload是重新加载上一次使用的nginx配置文件）
#启动emq
/usr/local/src/emqx-rel/_rel/emqx/bin/emqx start
echo "查看集群状态"
sleep 2 
/usr/local/src/emqx-rel/_rel/emqx/bin/emqx_ctl cluster status
