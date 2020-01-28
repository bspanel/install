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
#############################################################################################################
OS=$(lsb_release -s -i -c -r | xargs echo |sed 's; ;-;g' | grep Ubuntu)
if [ "$OS" = "Debian8" ]; then
  echo "• Добавляем репозиторий •"
  echo "deb http://ftp.ru.debian.org/debian/ jessie main" > /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ jessie main" >> /etc/apt/sources.list
  echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
  echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list
  echo "deb http://ftp.ru.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ jessie-updates main" >> /etc/apt/sources.list
fi
if [ "$OS" = "Debian7" ]; then
  log_t "• Добавляем репозиторий •"
  echo "deb http://ftp.ru.debian.org/debian/ wheezy main" > /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ wheezy main" >> /etc/apt/sources.list
  echo "deb http://security.debian.org/ wheezy/updates main" >> /etc/apt/sources.list
  echo "deb-src http://security.debian.org/ wheezy/updates main" >> /etc/apt/sources.list
  echo "deb http://ftp.ru.debian.org/debian/ wheezy-updates main" >> /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ wheezy-updates main" >> /etc/apt/sources.list
fi
if [ "$OS" = "Debian9" ]; then
  echo "• Добавляем репозиторий •"
  echo "deb http://ftp.ru.debian.org/debian/ stretch main" > /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ stretch main" >> /etc/apt/sources.list
  echo "deb http://security.debian.org/ stretch/updates main" >> /etc/apt/sources.list
  echo "deb-src http://security.debian.org/ stretch/updates main" >> /etc/apt/sources.list
  echo "deb http://ftp.ru.debian.org/debian/ stretch-updates main" >> /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ stretch-updates main" >> /etc/apt/sources.list
  wget http://www.dotdeb.org/dotdeb.gpg
  apt-key add dotdeb.gpg
  rm dotdeb.gpg
fi