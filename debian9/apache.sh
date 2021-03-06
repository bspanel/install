#!/bin/sh
. /root/install/debian8/config
MIRROR='http://cdn.bspanel.ru'
IPVDS=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
VER=`cat /etc/issue.net | awk '{print $1$3}'`
port=8080
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
echo "• Устанавливаем и настраиваем ${red}Apache2${green} •"
apt-get install -y apache2 apache2-dev  > /dev/null 2>&1 && check
echo "• Включаем модуль ${red}Apache2${green} •"
a2enmod php5.6 > /dev/null 2>&1 && check
echo "• Включаем модуль ${red}mod_rewrite${green} для ${red}Apache2${green} •"
a2enmod rewrite > /dev/null 2>&1 && check
echo "• Перезагружаем ${red}Apache2${green} •"
service apache2 restart	> /dev/null 2>&1 && check
echo "• Меняем порт ${red}Apache2${green} •"
sed -i "s/80/${port}/g" /etc/apache2/ports.conf > /dev/null 2>&1 && check
echo "• Создаем хост в ${red}Apache2${green} - создание файлов виртуальных хостов •"
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/.000-default.conf
FILE='/etc/apache2/sites-available/000-default.conf'
  echo "<VirtualHost *:8080>">$FILE
  echo "	ServerName $DOMAIN">>$FILE
  echo "	DocumentRoot /var/www">>$FILE
  echo "	<Directory /var/www/>">>$FILE
  echo "	Options Indexes FollowSymLinks MultiViews">>$FILE
  echo "	AllowOverride All">>$FILE
  echo "	Order allow,deny">>$FILE
  echo "	allow from all">>$FILE
  echo "	</Directory>">>$FILE
  echo "	ErrorLog \${APACHE_LOG_DIR}/error.log">>$FILE
  echo "	LogLevel warn">>$FILE
  echo "	CustomLog \${APACHE_LOG_DIR}/access.log combined">>$FILE
  echo "</VirtualHost>">>$FILE
check
echo "• Перезагружаем ${red}Apache2${green} •"
service apache2 restart	> /dev/null 2>&1 && check
echo "• Проверка ${red}Apache2${green} •" && check