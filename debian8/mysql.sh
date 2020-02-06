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
echo "• Устанавливаем ${red}MYSQL${green} •"
echo mysql-server mysql-server/root_password select "$MYPASS" | debconf-set-selections
echo mysql-server mysql-server/root_password_again select "$MYPASS" | debconf-set-selections

apt-get install -y mysql-server > /dev/null 2>&1
echo "• Устанавливаем ${red}phpMyAdmin${green} •"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
apt-get install -y phpmyadmin > /dev/null 2>&1 && check
check