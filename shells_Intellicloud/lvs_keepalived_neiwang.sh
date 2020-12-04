#!/usr/bin/bash 
yum -y install keepalived 

IP_ADDRESS=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g'  | awk -F' ' '{print $2}' | grep -v 32 |grep -v 172.17.0.1| awk -F'/' '{print $1}')
neiwang_VIP=`cat /root/shells/ip.txt | grep VIP | grep neiwang_VIP| awk -F':' '{print $2}'`
lvs_keepalive_neiwang1=`cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_neiwang1 | awk -F':' '{print $2}'`
lvs_keepalive_neiwang2=`cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_neiwang2 | awk -F':' '{print $2}'`
mysql_pxc1=`cat /root/shells/ip.txt | grep mysql_pxc | grep mysql_pxc1 | awk -F':' '{print $2}'`
mysql_pxc2=`cat /root/shells/ip.txt | grep mysql_pxc | grep mysql_pxc2 | awk -F':' '{print $2}'`
mysql_pxc3=`cat /root/shells/ip.txt | grep mysql_pxc | grep mysql_pxc3 | awk -F':' '{print $2}'`
fastdfs_tracker1=`cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker1 | awk -F':' '{print $2}'`
fastdfs_tracker2=`cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker2 | awk -F':' '{print $2}'`
redis_redis1=`cat /root/shells/ip.txt | grep redis | grep redis_redis1 | awk -F':' '{print $2}'`
redis_redis2=`cat /root/shells/ip.txt | grep redis | grep redis_redis2 | awk -F':' '{print $2}'`
redis_redis3=`cat /root/shells/ip.txt | grep redis | grep redis_redis3 | awk -F':' '{print $2}'`
rabbitmq_rabbitmq1=`cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq1 | awk -F':' '{print $2}'`
rabbitmq_rabbitmq2=`cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq2 | awk -F':' '{print $2}'`
rabbitmq_rabbitmq3=`cat /root/shells/ip.txt | grep rabbitmq | grep rabbitmq_rabbitmq3 | awk -F':' '{print $2}'`
emqx_emq1=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq1| awk -F':' '{print $2}'`
emqx_emq2=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq2| awk -F':' '{print $2}'`
emqx_emq3=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq3| awk -F':' '{print $2}'`



cat  <<EOF > /root/shells/lvs_dr_rs_neiwang.sh
ifconfig lo:0 ${neiwang_VIP} broadcast ${neiwang_VIP} netmask 255.255.255.255 up

route add -host ${neiwang_VIP} lo:0

echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore

echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce

echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore

echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

EOF


if [[ ${IP_ADDRESS} == ${lvs_keepalive_neiwang1} ]];then
            echo "选择了master"

cat  <<EOF > /root/shells/keepalived.conf_neiwang_master
vrrp_instance VI_1 {

    state MASTER

    interface eth0

    virtual_router_id 52

    priority 100

    advert_int 1

    authentication {

        auth_type PASS

        auth_pass 1111

    }

    virtual_ipaddress {

        ${neiwang_VIP}

    }

}

virtual_server ${neiwang_VIP} 3306 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${mysql_pxc1} 3306 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 3306

        }

    }



    real_server ${mysql_pxc2} 3306 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 3306

        }

    }

    real_server ${mysql_pxc3} 3306 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 3306

        }

    }


}

virtual_server ${neiwang_VIP} 22122 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${fastdfs_tracker1} 22122 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 22122

        }

    }



    real_server ${fastdfs_tracker2} 22122 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 22122

        }

    }
}

virtual_server ${neiwang_VIP} 6379 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${redis_redis1} 6379 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6379

        }

    }

    real_server ${redis_redis2} 6379 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6379

        }

    }

    real_server ${redis_redis3} 6379 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6379

        }

    }
}



virtual_server ${neiwang_VIP} 6380 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${redis_redis1} 6380 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6380

        }

    }

    real_server ${redis_redis2} 6380 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6380

        }

    }

    real_server ${redis_redis3} 6380 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6380

        }

    }
}


virtual_server ${neiwang_VIP} 6381 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${redis_redis1} 6381 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6381

        }

    }

    real_server ${redis_redis2} 6381 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6381

        }

    }

    real_server ${redis_redis3} 6381 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6381

        }

    }
}


virtual_server ${neiwang_VIP} 5672 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${rabbitmq_rabbitmq1} 5672 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 5672

        }

    }



    real_server ${rabbitmq_rabbitmq2} 5672 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 5672

        }

    }

    real_server ${rabbitmq_rabbitmq3} 5672 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 5672

        }

    }


}

virtual_server ${neiwang_VIP} 1882 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${emqx_emq1} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }



    real_server ${emqx_emq2} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }

    real_server ${emqx_emq3} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }

}

EOF

/usr/bin/cp /root/shells/keepalived.conf_neiwang_master /etc/keepalived/keepalived.conf

systemctl start keepalived

systemctl status keepalived

ip a



elif [[ ${IP_ADDRESS} == ${lvs_keepalive_neiwang2} ]];then
            echo "选择了backup"

cat  <<EOF > /root/shells/keepalived.conf_neiwang_backup

vrrp_instance VI_1 {

    state BACKUP

    interface eth0

    virtual_router_id 52

    priority 90

    advert_int 1

    authentication {

        auth_type PASS

        auth_pass 1111

    }

    virtual_ipaddress {

        ${neiwang_VIP}

    }

}

virtual_server ${neiwang_VIP} 3306 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${mysql_pxc1} 3306 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 3306

        }

    }



    real_server ${mysql_pxc2} 3306 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 3306

        }

    }

    real_server ${mysql_pxc3} 3306 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 3306

        }

    }


}

virtual_server ${neiwang_VIP} 22122 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${fastdfs_tracker1} 22122 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 22122

        }

    }



    real_server ${fastdfs_tracker2} 22122 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 22122

        }

    }
}

virtual_server ${neiwang_VIP} 6379 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${redis_redis1} 6379 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6379

        }

    }

    real_server ${redis_redis2} 6379 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6379

        }

    }

    real_server ${redis_redis3} 6379 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6379

        }

    }
}



virtual_server ${neiwang_VIP} 6380 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${redis_redis1} 6380 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6380

        }

    }

    real_server ${redis_redis2} 6380 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6380

        }

    }

    real_server ${redis_redis3} 6380 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6380

        }

    }
}


virtual_server ${neiwang_VIP} 6381 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${redis_redis1} 6381 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6381

        }

    }

    real_server ${redis_redis2} 6381 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6381

        }

    }

    real_server ${redis_redis3} 6381 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 6381

        }

    }
}


virtual_server ${neiwang_VIP} 5672 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${rabbitmq_rabbitmq1} 5672 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 5672

        }

    }



    real_server ${rabbitmq_rabbitmq2} 5672 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 5672

        }

    }

    real_server ${rabbitmq_rabbitmq3} 5672 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 5672

        }

    }


}

virtual_server ${neiwang_VIP} 1882 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${emqx_emq1} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }



    real_server ${emqx_emq2} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }

    real_server ${emqx_emq3} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }

}


EOF

/usr/bin/cp /root/shells/keepalived.conf_neiwang_backup /etc/keepalived/keepalived.conf

systemctl start keepalived

systemctl status keepalived

ip a

else
            echo "非法输入，请重新输入"
fi
