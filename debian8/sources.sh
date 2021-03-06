#!/bin/sh

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