#!/usr/bin/bash 
tmppasswd=`grep 'temporary password' /var/log/mysqld.log | head -1 | rev | cut -d ' ' -f 1 | rev` 
passwd="mect888!"
echo $tmppasswd
mysql -uroot -p"${tmppasswd}" --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'mect888\!';" -e "grant all privileges  on *.* to root@'%' identified by 'mect888\!';" -e "flush privileges;"

sleep 2

mysql -uroot -p"${passwd}" --connect-expired-password -e "CREATE USER 'sstuser'@'localhost' IDENTIFIED BY 's3cret';" -e "GRANT RELOAD,LOCK TABLES,PROCESS,REPLICATION CLIENT ON *.* TO ' sstuser' @'localhost';" -e "flush privileges;"



