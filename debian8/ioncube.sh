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
MODULES=$(php -i | grep extension_dir | awk '{print $NF}')
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
ARCH=$(getconf LONG_BIT)

# Если 32-бит
if [ $ARCH == "32" ]; then
  echo "${Cyan} Скачивание Ioncube Loader.. ${Color_Off}"
  wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz > /dev/null 2>&1

  echo "${Cyan} Распаковка Ioncube Loader.. ${Color_Off}"
  tar xvfz ioncube_loaders_lin_x86.tar.gz > /dev/null 2>&1
# Если 64-бит
else
  echo "${Cyan} • Скачивание Ioncube Loader • ${Color_Off}"
  wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz > /dev/null 2>&1 && check
  echo "${Cyan} • Распакуем файл • ${Color_Off}"
  tar xvfz ioncube_loaders_lin_x86-64.tar.gz > /dev/null 2>&1 && check
fi
rm /root/ioncube_loaders_lin_x86-64.tar.gz /root/ioncube_loaders_lin_x86.tar.gz > /dev/null 2>&1
echo "${Cyan} • Копирования файлов Ioncube Loader • ${Color_Off}" && check
sudo cp /root/ioncube/ioncube_loader_lin_${PHP_VERSION}.so $MODULES > /dev/null 2>&1
sed -i "3i\zend_extension = ${MODULES}/ioncube_loader_lin_${PHP_VERSION}.so" /etc/php5/apache2/php.ini > /dev/null 2>&1
rm -r /root/ioncube > /dev/null 2>&1
echo "${Cyan} Копирования успешно прошла!${Color_Off}" && check