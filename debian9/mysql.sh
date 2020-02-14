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
RED=$(tput setaf 1)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
white=$(tput setaf 7)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
LIME_YELLOW=$(tput setaf 190)
CYAN=$(tput setaf 6)
#############Цвета#############

echo "• Устанавливаем ${red}MySQL and phpMyAdmin${green} •"

wget $MIRROR/files/mysql/mysql-apt-config_0.8.14-1_all.deb > /dev/null 2>&1
export DEBIAN_FRONTEND=noninteractive > /dev/null 2>&1
echo mysql-apt-config mysql-apt-config/select-server select mysql-5.6 | debconf-set-selections > /dev/null 2>&1
echo mysql-apt-config mysql-apt-config/select-product select Ok | debconf-set-selections > /dev/null 2>&1
apt-get install -y ./mysql-apt-config_0.8.14-1_all.deb > /dev/null 2>&1
dpkg -i mysql-apt-config_0.8.14-1_all.deb > /dev/null 2>&1
echo mysql-community-server mysql-community-server/root-pass password "$MYPASS" | debconf-set-selections > /dev/null 2>&1
echo mysql-community-server mysql-community-server/re-root-pass password "$MYPASS" | debconf-set-selections > /dev/null 2>&1

apt-get update > /dev/null 2>&1
apt-get install -y mysql-server > /dev/null 2>&1

echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections > /dev/null 2>&1
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections > /dev/null 2>&1
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections > /dev/null 2>&1
echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections > /dev/null 2>&1
echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections > /dev/null 2>&1
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections > /dev/null 2>&1
apt-get install -y phpmyadmin > /dev/null 2>&1

service mysql restart > /dev/null 2>&1
rm mysql-apt-config_0.8.7-1_all.deb > /dev/null 2>&1
cd > /dev/null 2>&1

check