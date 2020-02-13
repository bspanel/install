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
echo "• Приступаем к установке ${red}Java 8${green} •"
wget javadl.sun.com/webapps/download/AutoDL?BundleId=106240 -O jre-linux.tar.gz > /dev/null 2>&1
tar xvfz jre-linux.tar.gz > /dev/null 2>&1
mkdir /usr/lib/jvm > /dev/null 2>&1
mv jre1.8.0_45 /usr/lib/jvm/jre1.8.0_45 > /dev/null 2>&1
update-alternatives --install /usr/bin/java java /usr/lib/jvm/jre1.8.0_45/bin/java 1 > /dev/null 2>&1
update-alternatives --config java> /dev/null 2>&1
rm jre-linux.tar.gz && check