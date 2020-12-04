#!/usr/bin/bash 
yum -y install keepalived 

IP_ADDRESS=$(ip a | grep inet | grep -v inet6 | grep -v 127 | sed 's/^[ \t]*//g'  | awk -F' ' '{print $2}' | grep -v 32 |grep -v 172.17.0.1| awk -F'/' '{print $1}')
waiwang_VIP=`cat /root/shells/ip.txt | grep VIP | grep waiwang_VIP| awk -F':' '{print $2}'`
lvs_keepalive_waiwang1=`cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_waiwang1 | awk -F':' '{print $2}'`
lvs_keepalive_waiwang2=`cat /root/shells/ip.txt | grep lvs+keepalive | grep lvs+keepalive_waiwang2 | awk -F':' '{print $2}'`

cat  <<EOF > /root/shells/lvs_dr_rs_waiwang.sh
ifconfig lo:0 ${waiwang_VIP} broadcast ${waiwang_VIP} netmask 255.255.255.255 up

route add -host ${waiwang_VIP} lo:0

echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore

echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce

echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore

echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce

EOF


if [[ ${IP_ADDRESS} == ${lvs_keepalive_waiwang1} ]];then
            echo "选择了master"

cat  <<EOF > /root/shells/keepalived.conf_waiwang_master
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

        ${waiwang_VIP}

    }

}

virtual_server ${waiwang_VIP} 80 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 80 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 80

        }

    }



    real_server ${lvs_keepalive_waiwang2} 80 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 80

        }

    }

}




virtual_server ${waiwang_VIP} 443 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 443 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 443

        }

    }



    real_server ${lvs_keepalive_waiwang2} 443 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 443

        }

    }

}


virtual_server ${waiwang_VIP} 1883 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 1883 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1883

        }

    }



    real_server ${lvs_keepalive_waiwang2} 1883 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1883

        }

    }
}

virtual_server ${waiwang_VIP} 1882 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }



    real_server ${lvs_keepalive_waiwang2} 1882 {

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

/usr/bin/cp /root/shells/keepalived.conf_waiwang_master /etc/keepalived/keepalived.conf

systemctl start keepalived

systemctl status keepalived

ip a



elif [[ ${IP_ADDRESS} == ${lvs_keepalive_waiwang2} ]];then
            echo "选择了backup"

cat  <<EOF > /root/shells/keepalived.conf_waiwang_backup
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

        ${waiwang_VIP}

    }

}

virtual_server ${waiwang_VIP} 80 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 80 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 80

        }

    }



    real_server ${lvs_keepalive_waiwang2} 80 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 80

        }

    }

}




virtual_server ${waiwang_VIP} 443 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 443 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 443

        }

    }



    real_server ${lvs_keepalive_waiwang2} 443 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 443

        }

    }

}


virtual_server ${waiwang_VIP} 1883 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 1883 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1883

        }

    }



    real_server ${lvs_keepalive_waiwang2} 1883 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1883

        }

    }
}

virtual_server ${waiwang_VIP} 1882 {

    delay_loop 6

    lb_algo rr

    lb_kind DR

    persistence_timeout 0

    protocol TCP



    real_server ${lvs_keepalive_waiwang1} 1882 {

        weight 1

        TCP_CHECK {

            connect_timeout 10

            nb_get_retry 3

            delay_before_retry 3

            connect_port 1882

        }

    }



    real_server ${lvs_keepalive_waiwang2} 1882 {

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

/usr/bin/cp /root/shells/keepalived.conf_waiwang_backup /etc/keepalived/keepalived.conf

systemctl start keepalived

systemctl status keepalived

ip a

else
            echo "非法输入，请重新输入"
fi
