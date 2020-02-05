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
red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)
blue=$(tput setaf 4)
orange=$(tput setaf 3)
pink=$(tput setaf 5)
cyan=$(tput setaf 6)
#############Цвета#############
echo "• • Началась установка ${red}BSPanel${green} в каталог ${red}/var/www${green} • •"
cd ~ > /dev/null 2>&1
cd /var/www/ > /dev/null 2>&1
wget $MIRROR/files/debian/bspanel.zip > /dev/null 2>&1
unzip bspanel.zip > /dev/null 2>&1
rm bspanel.zip > /dev/null 2>&1
cd ~ > /dev/null 2>&1 && check

echo "• Выдаем права на файлы •"
chown -R www-data:www-data /var/www/ > /dev/null 2>&1
chmod -R 775 /var/www/ > /dev/null 2>&1 && check
echo "• Создаем базу данных и загружаем дамп базы данных от ${red}BSPanel${green} •"
wget $MIRROR/files/debian/bspanel.sql > /dev/null 2>&1
MP=$MYPASS
VP=$VPASS
IP=$DOMAIN
IP1=$IPVDS
new_pass=$(pwgen -cns -1 7)
account_pass=`wget -qO- http://system.bspanel.ru/api/md5.php?passwd=${new_pass} | sed -e 's/<[^>]*>//g'`
sed -i "s/mysqlp/${MP}/g" /var/www/system/data/mysql.php
sed -i "s/bspanel_addr/${IP1}/g" /var/www/system/data/web.php
sed -i "s/bspanel_pass/${VP}/g" /var/www/system/data/web.php
sed -i "s/bspanel_pm/${IP}/g" /var/www/system/data/web.php
sed -i "s/bspanel_dm/${IP}/g" /var/www/system/data/web.php
sed -i "s/domain_bsp/${IP}/g" /var/www/system/data/config.php
sed -i "s/IPADDR/${IP1}/g" /var/www/system/data/config.php
sed -i "s/key123/${CRONKEY}/g" /var/www/system/data/config.php
sed -i "s/bspanel_random_passwd/${new_pass}/g" /var/www/system/data/config.php
sed -i "s/domain_bsp/${IP}/g" /root/bspanel.sql
sed -i "s/IPADDR/${IP1}/g" /root/bspanel.sql
sed -i "s/sqlpass/${MP}/g" /root/bspanel.sql
# sed -i "s/sshpass/${VP}/g" /root/bspanel.sql
sed -i "s/new_pass_account/${account_pass}/g" /root/bspanel.sql
sed -i "$IP1 $DOMAIN" /etc/hosts
mysql -u root -p$MYPASS -e "CREATE DATABASE bspanel CHARACTER SET utf8 COLLATE utf8_general_ci;" > /dev/null 2>&1
mysql -u root -p$MYPASS bspanel < bspanel.sql > /dev/null 2>&1
rm bspanel.sql > /dev/null 2>&1 && check

  cd /var/www/system/sections/license > /dev/null 2>&1
  rm index.php > /dev/null 2>&1
  wget cdn.bspanel.ru/files/fix/license.zip > /dev/null 2>&1
  unzip license.zip > /dev/null 2>&1
  rm license.zip > /dev/null 2>&1
  cd ~