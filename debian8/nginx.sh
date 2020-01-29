#!/bin/sh
. /root/install/debian8/config
MIRROR='http://cdn.bspanel.ru'
IPVDS=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
VER=`cat /etc/issue.net | awk '{print $1$3}'`
check()
{
  if [ $? -eq 0 ]; then
  echo "${green}[OK]${green}"
  tput sgr0
  else
  echo "${red}[FAIL]${red}"
  tput sgr0
  fi
}
#############Цвета#############
red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)
blue=$(tput setaf 4)
orange=$(tput setaf 3)
pink=$(tput setaf 5)
cyan=$(tput setaf 6)
#############Цвета#############
echo "Устанавливаем Nginx"
apt-get install nginx
sudo /etc/init.d/nginx stop
echo "Настройка проксирования в Nginx"
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/nginx.conf
FILE='/etc/nginx/nginx.conf'
  echo "user www-data;">>$FILE
  echo "worker_processes $YADRO;">>$FILE
  echo "">>$FILE
  echo "error_log  /var/log/nginx/error.log;">>$FILE
  echo "pid        /var/run/nginx.pid;">>$FILE
  echo "events {">>$FILE
  echo "worker_connections  1024;">>$FILE
  echo "}">>$FILE
  echo "http {">>$FILE
  echo "	include       /etc/nginx/mime.types;">>$FILE
  echo "	default_type  application/octet-stream;">>$FILE
  echo "	access_log  /var/log/nginx/access.log;">>$FILE
  echo "	sendfile        on;">>$FILE
  echo "	tcp_nopush     on;">>$FILE
  echo "	keepalive_timeout  2;">>$FILE
  echo "	tcp_nodelay        on;">>$FILE
  echo "	gzip  on;">>$FILE
  echo "	gzip_comp_level 3;">>$FILE
  echo "	gzip_proxied any;">>$FILE
  echo "	gzip_types text/plain text/html text/css application/x-javascript text/xml application/xml application/xml+rss text/javascript;">>$FILE
  echo "	include /etc/nginx/conf.d/*.conf;">>$FILE
  echo "	include /etc/nginx/sites-enabled/*;">>$FILE
  echo "}">>$FILE
sudo /etc/init.d/nginx stop
FILE='/etc/nginx/sites-available/bspanel'
echo "upstream backend {
server 127.0.0.1:8080;
 }
server {
listen   80;
server_name www.$DOMAIN $DOMAIN;
access_log /var/log/nginx/access.log;
error_log /var/log/nginx/error.log;
location / {
location ~ [^/]\.ph(p\d*|tml)$ {
try_files /does_not_exists @fallback;
    }
location ~* ^.+\.(jpg|jpeg|gif|png|svg|js|css|mp3|ogg|mpe?g|avi|zip|gz|bz2?|rar|swf)$ {
try_files $uri $uri/ @fallback;
}
location / {
try_files /does_not_exists @fallback;
    }
}
location @fallback {
proxy_pass http://127.0.0.1:8080;
proxy_redirect http://127.0.0.1:8080 /;
proxy_set_header Host $host;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Port $server_port;
    }
} " >$FILE
  sudo ln -s /etc/nginx/sites-available/bspanel /etc/nginx/sites-enabled/bspanel
  mv /root/install/debian8/proxy.conf /etc/nginx/proxy.conf
  service nginx start && check
