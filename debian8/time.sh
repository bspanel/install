#!/bin/sh

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
  echo -n "${green}[OK]${green}"
  tput sgr0
  else
  echo -n "${red}[FAIL]${red}"
  tput sgr0
  fi
}
###################################Время###################################################################
echo "• Настраиваем время на сервере •"
echo "Europe/Moscow" > /etc/timezone
dpkg-reconfigure tzdata -f noninteractive > /dev/null 2>&1
sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5/cli/php.ini > /dev/null 2>&1
sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5/apache2/php.ini > /dev/null 2>&1
check
###################################Время###################################################################