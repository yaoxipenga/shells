#!/usr/bin/bash 
systemctl stop mysql@bootstrap.service
ps -ef | grep mysqld
rm -rf /home/mysqldata
rm -rf /data
rm -rf /var/log/mysqld.log
