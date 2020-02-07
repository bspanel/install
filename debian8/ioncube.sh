#!/bin/sh
. /root/install/debian8/config
MIRROR='http://cdn.bspanel.ru'
IPVDS=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
VER=`cat /etc/issue.net | awk '{print $1$3}'`
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
echo "• Приступаем к установке ${red}Ioncube Loader${green} •"
wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.zip
unzip ioncube_loaders_lin_x86-64.zip
cp ioncube/ioncube_loader_lin_5.6.so /usr/lib/php5/20131226/
cp ioncube/ioncube_loader_lin_5.6_ts.so /usr/lib/php5/20131226/
rm -R ioncube*
echo "zend_extension=ioncube_loader_lin_5.6.so">>"/etc/php5/apache2/php.ini"
echo "zend_extension=ioncube_loader_lin_5.6.so">>"/etc/php5/cli/php.ini"
check