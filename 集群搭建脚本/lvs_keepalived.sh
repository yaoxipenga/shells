#!/usr/bin/bash 
yum -y install keepalived 

cp keepalived.conf /etc/keepalived/keepalived.conf 

systemctl start keepalived 

systemctl status keepalived 

ip a 
