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
sudo /etc/init.d/nginx start
echo "Настройка проксирования в Nginx"
sudo rm /etc/nginx/sites-enabled/default
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
  echo "upstream backend {">>$FILE
  echo "    server 127.0.0.1:8080;">>$FILE
  echo "}">>$FILE
  echo "">>$FILE
  echo "server {">>$FILE
  echo "    listen   80;">>$FILE
  echo "    server_name www.$DOMAIN $DOMAIN;">>$FILE
  echo "    access_log /var/www/logs/nginx_access.log;">>$FILE
  echo "    error_log /var/www/logs/nginx_error.log;">>$FILE
  echo "location / {">>$FILE
  echo "	proxy_pass  http://backend;">>$FILE
  echo "	include     /etc/nginx/proxy.conf;">>$FILE
  echo "}">>$FILE
  echo "	location ~* \.(jpg|jpeg|gif|png|ico|css|bmp|swf|js)$ {">>$FILE
  echo "	root /var/www/;">>$FILE
  echo "	}">>$FILE
  echo "}">>$FILE
  sudo ln -s /etc/nginx/sites-available/bspanel /etc/nginx/sites-enabled/bspanel
  service nginx start && check
