#!/bin/sh
. /root/install/debian8/config
MIRROR='http://cdn.bspanel.ru'
IPVDS=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
VER=`cat /etc/issue.net | awk '{print $1$3}'`
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
wget http://core.brainycp.com/src/package/ioncube_el6_x86-64.tar.gz &>/dev/null
tar zxf ioncube_el6_x86-64.tar.gz
cp /etc/brainy/src/ioncube/ioncube_loader_lin_5.6.so /etc/brainy/src/compiled/php5/ioncube_loader_lin_5.6.so
cp /etc/brainy/src/ioncube/ioncube_loader_lin_5.6_ts.so /etc/brainy/src/compiled/php5/ioncube_loader_lin_5.6_ts.so
echo "zend_extension=ioncube_loader_lin_5.5.so">>"/etc/php5/apache2/php.ini"
echo "zend_extension=ioncube_loader_lin_5.5.so">>"/etc/php5/cli/php.ini"