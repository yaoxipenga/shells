#!/usr/bin/bash 
#获取阿里源
wget -O /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
yum clean all 
yum makecache 
#安装nginx
yum -y install nginx 
#复制ssl到指定目录
cp -r /root/shells/ssl /etc/nginx/

cat <<EOF > /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user root;
worker_processes auto;
worker_rlimit_nofile 65535;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    use epoll; #支持大量连接和非活动连接
    multi_accept on; #nginx在已经得到一个新连接的通知时，接收尽可能多的连接
    accept_mutex on; #防止惊群现象发生，默认为on
    worker_connections 65535;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for" '
                      '\$connection \$upstream_addr '
                      '\$upstream_response_time \$request_time';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   60;
    types_hash_max_size 2048;
    server_names_hash_bucket_size 128;
    client_header_buffer_size 4k;
    open_file_cache max=102400 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 1;
    client_header_timeout 15;
    client_body_timeout 15;
    reset_timedout_connection on;
    send_timeout 15;
    server_tokens off;
    client_max_body_size 10m;
    large_client_header_buffers 4 4k;

    gzip on;
    gzip_min_length   1k;
    gzip_buffers     4 16k;
    gzip_http_version 1.0;
    gzip_comp_level 2;
    gzip_types       text/plain application/x-javascript text/css application/xml;
    gzip_vary on;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

     include /etc/nginx/conf.d/http/*.conf;
}


stream {
    log_format proxy '\$remote_addr [\$time_local] '
                 '\$protocol \$status \$bytes_sent \$bytes_received '
                 '\$session_time "\$upstream_addr" '
                 '"\$upstream_bytes_sent" "\$upstream_bytes_received" "\$upstream_connect_time"';

    access_log /var/log/nginx/tcp-access.log proxy;

    include /etc/nginx/conf.d/tcp/*.conf;
}
EOF

gateway_ip_1=`cat /root/shells/ip.txt | grep eureka-gateway-client | awk -F':' '{print $2}' | awk -F',' '{print $1}'`
gateway_ip_2=`cat /root/shells/ip.txt | grep eureka-gateway-client | awk -F':' '{print $2}' | awk -F',' '{print $2}'`
gateway_ip_3=`cat /root/shells/ip.txt | grep eureka-gateway-client | awk -F':' '{print $2}' | awk -F',' '{print $3}'`

fastdfs_ip_1=`cat /root/shells/ip.txt | grep fast-dfs | awk -F':' '{print $2}' | awk -F',' '{print $1}'`
fastdfs_ip_2=`cat /root/shells/ip.txt | grep fast-dfs | awk -F':' '{print $2}' | awk -F',' '{print $2}'`
fastdfs_ip_3=`cat /root/shells/ip.txt | grep fast-dfs | awk -F':' '{print $2}' | awk -F',' '{print $3}'`

emq_ip_address1=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq1| awk -F':' '{print $2}'`
emq_ip_address2=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq2| awk -F':' '{print $2}'`
emq_ip_address3=`cat /root/shells/ip.txt | grep emqx | grep emqx_emq3| awk -F':' '{print $2}'`

TRACKER_SERVER1=`cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker1 | awk -F':' '{print $2}'`
TRACKER_SERVER2=`cat /root/shells/ip.txt | grep fastdfs_tracker | grep fastdfs_tracker2 | awk -F':' '{print $2}'`

choice=`cat /root/shells/ip.txt | grep domain | head -1 | awk -F'=' '{print $2}'`
online_domain="online.medciot.com"
test_domain="test.medciot.com"
dev_domain="dev.medciot.com"
szonline_domain="szonline.medciot.com"

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


#新建相关文件夹
mkdir -p /etc/nginx/conf.d/{http,tcp}
cat <<EOF >/etc/nginx/conf.d/http/80.conf

upstream medciot1{
     #ip_hash;
     server ${gateway_ip_1}:8800; #网关微服务地址和端口号
     server ${gateway_ip_2}:8800;
     server ${gateway_ip_3}:8800;
}

upstream medciot_fast_dfs{
        ip_hash;
        server ${fastdfs_ip_1}:8776;
        server ${fastdfs_ip_2}:8776;
        server ${fastdfs_ip_3}:8776;
    }


server {
        listen 80;
        server_name ${domain};

        #listen 443 ssl;
        #server_name  ${domain};
        #root         /usr/share/nginx/html/dist;

        #ssl_certificate "/etc/nginx/ssl/szonline/1_szonline.medciot.com_bundle.crt";
        #ssl_certificate_key "/etc/nginx/ssl/szonline/2_szonline.medciot.com.key";
        #ssl_session_timeout 5m;
        #ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        #ssl_prefer_server_ciphers on;


        location / {
            index index.html index.htm;
            root         /usr/share/nginx/html/dist;
            try_files \$uri \$uri/ /index.html;
        }



    location /api/ {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Credentials' 'true';
                add_header 'Access-Control-Allow-Methods' '*';
                add_header 'Access-Control-Max-Age' '18000L';
                add_header 'Access-Control-Allow-Headers' '*';

        client_max_body_size    1000m;

        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://medciot1/;
        }
  
    location /api2/file/ {

        client_max_body_size    1000m;

        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        proxy_pass http://medciot_fast_dfs/;
    }


    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root html;
    }
}
EOF

cat <<EOF > /etc/nginx/conf.d/http/443.conf
upstream medciot{
     #ip_hash;
     server ${gateway_ip_1}:8800; #网关微服务地址和端口号
     server ${gateway_ip_2}:8800;
     server ${gateway_ip_3}:8800;
}

server {

        listen 443 ssl;
        server_name ${domain};

        ssl_certificate /etc/nginx/ssl/1_szonline.medciot.com_bundle.crt;
        ssl_certificate_key /etc/nginx/ssl/2_szonline.medciot.com.key;
        #ssl_session_timeout 5m;
        #ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        #ssl_prefer_server_ciphers on;


        location / {
            index index.html index.htm;
            root         /usr/share/nginx/html/dist;
            try_files \$uri \$uri/ /index.html;
        }



    location /api/ {
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Credentials' 'true';
                add_header 'Access-Control-Allow-Methods' '*';
                add_header 'Access-Control-Max-Age' '18000L';
                add_header 'Access-Control-Allow-Headers' '*';

        client_max_body_size    1000m;

        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_pass http://medciot/;
        }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root html;
    }
}
EOF
cat <<EOF >/etc/nginx/conf.d/tcp/1882.conf
server {
    error_log /var/log/nginx/1882_error.log;
    listen 1882;
    proxy_connect_timeout 600s;
    proxy_pass medciot;
}
EOF
cat <<EOF >/etc/nginx/conf.d/tcp/1883.conf
upstream medciot{
    #server 10.10.1.90:1882; #这个配置无论写哪个tcp的配置文件里都可以，emq的端口必须写无鉴权的
    server ${emq_ip_address1}:1882;
    server ${emq_ip_address2}:1882;
    server ${emq_ip_address3}:1882;
}
server {
    error_log /var/log/nginx/1883_error.log;
    listen 1883 ssl;
    proxy_connect_timeout 600s;
    #proxy_timeout 3s;
    proxy_pass medciot;

    ssl_certificate       /etc/nginx/ssl/server/online.medciot.com.crt;
    ssl_certificate_key   /etc/nginx/ssl/server/online.medciot.com.key;
    ssl_protocols         SSLv3 TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers           HIGH:!aNULL:!MD5;
    ssl_session_cache     shared:SSL:20m;
    ssl_session_timeout   4h;
    ssl_handshake_timeout 30s;
}
EOF
cat <<EOF >/etc/nginx/conf.d/tcp/22122.conf
upstream tracker{
            server ${TRACKER_SERVER1}:22122;
            server ${TRACKER_SERVER2}:22122;
        }

server {
    listen 22122;
    proxy_pass tracker;
}
EOF
