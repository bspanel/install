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
	echo "• Устанавливаем ${red} Mysql ${red}${green}.${red}5.6${green} •"
	wget https://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb > /dev/null 2>&1
	export DEBIAN_FRONTEND=noninteractive
	dpkg -i mysql-apt-config_0.8.7-1_all.deb > /dev/null 2>&1
	sed -i "s/5.7/5.6/g" /etc/apt/sources.list.d/mysql.list > /dev/null 2>&1
	apt-get update > /dev/null 2>&1
	apt-get --yes --force-yes install mysql-server > /dev/null 2>&1
  service mysql stop
  sudo mysqld_safe --skip-grant-tables --skip-networking
	# Make sure that NOBODY can access the server without a password
	mysql -e "UPDATE mysql.user SET Password = PASSWORD('$MYPASS') WHERE User = 'root'" > /dev/null 2>&1
	# Kill off the demo database
	mysql -e "update mysql.user set plugin='' where User='root';" > /dev/null 2>&1
	# Make our changes take effect
	mysql -e "FLUSH PRIVILEGES" > /dev/null 2>&1
  killall -9 mysqld mysqld_safe
  service mysql start
	# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
	sudo mysql_upgrade -u root -p$MYPASS --force --upgrade-system-tables > /dev/null 2>&1
	service mysql restart > /dev/null 2>&1
	rm mysql-apt-config_0.8.7-1_all.deb > /dev/null 2>&1
  check
	echo "• Устанавливаем ${red}phpMyAdmin${green} •"
	echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections
	echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections
	echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections
	echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
	apt-get install -y phpmyadmin > /dev/null 2>&1
  check