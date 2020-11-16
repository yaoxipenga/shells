#!/usr/bin/bash 
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

yum clean all 
yum makecache 

curl -o /etc/yum.repos.d/docker-ce.repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

yum install docker-ce-17.06.0.ce-1.el7.centos.x86_64 -y

systemctl enable docker

systemctl  start docker

cat > /etc/docker/daemon.json <<EOF

{

     "registry-mirrors": ["https://ui5lsypg.mirror.aliyuncs.com"]

}

EOF

sudo systemctl daemon-reload

sudo systemctl restart docker

 

sudo curl -L https://mirrors.aliyun.com/docker-toolbox/linux/compose/1.21.2/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose --version

docker pull java:8

docker images 


