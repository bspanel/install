#!/bin/sh
MIRROR='http://cdn.bspanel.ru'
IPVDS=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
VER=`cat /etc/issue.net | awk '{print $1$3}'`
#############Цвета#############
Info()
{
	Infon "$@\n"
}
Infon() {
	printf "\033[1;32m$@\033[0m"
}
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
bspanelsh()
{
clear
echo "${orange}-------------------------------------------------------------------------------"
Info "Здравствуйте, данный скрипт поможет Вам установить ${red}BSPanel${blue} на Debian 8
Вам после установки, ни чего делать не надо.
Скрипт за Вас всё установить кроме игр!"
echo "${orange}-------------------------------------------------------------------------------"
while true; do
read -p "${green}Вы уверены, что хотите установить полностью ${red}BSPanel${green}?(${red}Y${green}/${red}N${green}): " yn
case $yn in
  [Yy]* ) break;;
  [Nn]* ) sh /root/install/bspanel_starter.sh;;
  * ) echo "Ответьте, пожалуйста ${red}Y${green} или ${red}N${green}.";;
esac
done
read -p "${cyan}Пожалуйста, введите ${red}домен ${cyan}или ${red}IP${green}: ${cyan}" DOMAIN
sed -i "s/domain/${DOMAIN}/g" /root/install/debian8/config
read -p "${cyan}Пожалуйста, введите ${red}IP${green}: ${cyan}" IPADR
sed -i "s/ipadress/${IPADR}/g" /root/install/debian8/config
read -p "${cyan}Пожалуйста, введите ${red}количество ядер${green}: ${cyan}" YADRO
sed -i "s/yadro/${YADRO}/g" /root/install/debian8/config
read -p "${cyan}Введите пароль от root${green}: ${yellow}" VPASS
echo "• Начинаем установку ${red}BSPanel${green} •"
echo "• Обновляем пакеты •"
apt-get update > /dev/null 2>&1 && check
echo "• Устанавливаем пакеты ${red}pwgen wget dialog sudo unzip nano memcached git!${red} •"
apt-get install -y apt-utils pwgen wget dialog sudo unzip nano memcached git > /dev/null 2>&1 && check
MYPASS=$(pwgen -cns -1 16)
sed -i "s/mypass/${MYPASS}/g" /root/install/debian8/config
MYPASS2=$(pwgen -cns -1 16) 
###################################Пакеты##################################################################
echo "• Добавляем пакеты •"
sh /root/install/debian8/sources.sh && check
echo "• Обновляем пакеты •"
apt-get update -y > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1 && check
###################################Пакеты###################################################################

###################################PHP##################################################################
sh /root/install/debian8/php.sh
###################################PHP###################################################################

###################################Apache2###################################################################
sh /root/install/debian8/apache.sh
###################################Apache2###################################################################

###################################Nginx###################################################################
sh /root/install/debian8/nginx.sh
###################################Nginx###################################################################

###################################MYSQL###################################################################
sh /root/install/debian8/mysql.sh
###################################MYSQl###################################################################
echo "• Устанавливаем библиотеку ${red}SSH2${green} •"
if [ "$OS" = "" ]; then
apt-get install -y curl php5-ssh2 > /dev/null 2>&1
else
apt-get install -y libssh2-php > /dev/null 2>&1
fi
check
###################################CRON###################################################################
sh /root/install/debian8/cron.sh
###################################CRON###################################################################
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

echo "• Устанавливаем необходимые пакеты для ${red}серверной части​${green} •"
apt-get install -y lsb-release > /dev/null 2>&1
apt-get install -y lib32stdc++6 > /dev/null 2>&1
apt-get install -y libreadline5 > /dev/null 2>&1
OS=$(lsb_release -s -i -c -r | xargs echo |sed 's; ;-;g' | grep Ubuntu)
if [ "$OS" = "" ]; then
  sudo dpkg --add-architecture i386 > /dev/null 2>&1
  sudo apt-get update > /dev/null 2>&1
  sudo apt-get install -y gcc-multilib > /dev/null 2>&1
else
  cd /etc/apt/sources.list.d > /dev/null 2>&1
  echo "deb http://old-releases.ubuntu.com/ubuntu/ raring main restricted universe multiverse" >ia32-libs-raring.list > /dev/null 2>&1
  apt-get update > /dev/null 2>&1
  sudo apt-get install -y gcc-multilib > /dev/null 2>&1
fi
apt-get install -y sudo screen htop nano tcpdump ethstatus ssh zip unzip mc qstat gdb lib32gcc1 nload ntpdate lsof > /dev/null 2>&1
apt-get install -y lib32z1 > /dev/null 2>&1 && check
echo "• Приступаем к установке ${red}Java 8${green} •"
wget javadl.sun.com/webapps/download/AutoDL?BundleId=106240 -O jre-linux.tar.gz > /dev/null 2>&1
tar xvfz jre-linux.tar.gz > /dev/null 2>&1
mkdir /usr/lib/jvm > /dev/null 2>&1
mv jre1.8.0_45 /usr/lib/jvm/jre1.8.0_45 > /dev/null 2>&1
update-alternatives --install /usr/bin/java java /usr/lib/jvm/jre1.8.0_45/bin/java 1 > /dev/null 2>&1
update-alternatives --config java> /dev/null 2>&1
rm jre-linux.tar.gz && check
echo "• Устанавливаем и настраиваем ${red}iptables${green} + ${red}rclocal${green} •"
wget -O rclocal $MIRROR/files/debian/rclocal/rclocal.txt > /dev/null 2>&1
sed -i '14d' /etc/rc.local > /dev/null 2>&1
cat rclocal >> /etc/rc.local > /dev/null 2>&1
touch /root/iptables_block > /dev/null 2>&1
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "UTC=no" >> /etc/default/rcS
rm -rf rclocal > /dev/null 2>&1 && check
echo "• Устанавливаем и настраиваем ${red}iptables${green} + ${red}geoip${green} •"
sudo apt-get --yes --force-yes install xtables-addons-common > /dev/null 2>&1
sudo apt-get --yes --force-yes install libtext-csv-xs-perl libxml-csv-perl libtext-csv-perl unzip > /dev/null 2>&1
sudo mkdir -p /usr/share/xt_geoip/ > /dev/null 2>&1
mkdir geoiptmp > /dev/null 2>&1
cd geoiptmp /usr/lib/xtables-addons/xt_geoip_dl > /dev/null 2>&1
sudo /usr/lib/xtables-addons/xt_geoip_build GeoIPv6.csv GeoIPCountryWhois.csv -D /usr/share/xt_geoip > /dev/null 2>&1
cd ~
rm -rf geoiptmp > /dev/null 2>&1 && check
echo "• Включаем ${red}Nginx${green} для модуля ${red}FastDL${green} •"
wget -O nginx $MIRROR/files/debian/nginx/nginx.txt > /dev/null 2>&1
service apache2 stop > /dev/null 2>&1
apt-get install -y nginx > /dev/null 2>&1
mkdir -p /var/nginx/ > /dev/null 2>&1
rm -rf /etc/nginx/nginx.conf > /dev/null 2>&1
mv nginx /etc/nginx/nginx.conf > /dev/null 2>&1
service nginx restart > /dev/null 2>&1
service apache2 start > /dev/null 2>&1
rm -rf nginx > /dev/null 2>&1 && check
echo "• Устанавливаем и настраиваем ${red}ProFTPd${green} •"
wget -O proftpd $MIRROR/files/debian/proftpd/proftpd.txt > /dev/null 2>&1
wget -O proftpd_modules $MIRROR/files/debian/proftpd/proftpd_modules.txt > /dev/null 2>&1
wget -O proftpd_sql $MIRROR/files/debian/proftpd/proftpd_sql.txt > /dev/null 2>&1
echo PURGE | debconf-communicate proftpd-basic > /dev/null 2>&1
echo proftpd-basic shared/proftpd/inetd_or_standalone select standalone | debconf-set-selections
apt-get install -y proftpd-basic proftpd-mod-mysql > /dev/null 2>&1
rm -rf /etc/proftpd/proftpd.conf > /dev/null 2>&1
rm -rf /etc/proftpd/modules.conf > /dev/null 2>&1
rm -rf /etc/proftpd/sql.conf > /dev/null 2>&1
mv proftpd /etc/proftpd/proftpd.conf > /dev/null 2>&1
mv proftpd_modules /etc/proftpd/modules.conf > /dev/null 2>&1
mv proftpd_sql /etc/proftpd/sql.conf > /dev/null 2>&1
rm -rf proftpd > /dev/null 2>&1
rm -rf proftpd_modules > /dev/null 2>&1
rm -rf proftpd_sql > /dev/null 2>&1
mkdir -p /copy /servers /servers/cs /servers/cssold /servers/css /servers/csgo /servers/samp /servers/crmp /servers/mta /servers/mc /path/steam /var/nginx
mkdir -p /path/cs /path/css /path/cssold /path/csgo /path/samp /path/crmp /path/mta /path/mc
mkdir -p /path/update/cs /path/update/css /path/update/cssold /path/update/csgo /path/update/samp /path/update/crmp /path/update/mta /path/update/mc
cd /path/steam && wget http://media.steampowered.com/client/steamcmd_linux.tar.gz > /dev/null 2>&1 && tar xvfz steamcmd_linux.tar.gz > /dev/null 2>&1 && rm steamcmd_linux.tar.gz > /dev/null 2>&1
cd ~
groupmod -g 998 `cat /etc/group | grep :1000 | awk -F":" '{print $1}'` > /dev/null 2>&1
groupadd -g 1000 servers; > /dev/null 2>&1
chmod 711 /servers
chown root:servers /servers
chmod 711 /servers/cs
chown root:servers /servers/cs
chmod 711 /servers/cssold
chown root:servers /servers/cssold
chmod 711 /servers/css
chown root:servers /servers/css
chmod 711 /servers/csgo
chown root:servers /servers/csgo
chmod 711 /servers/samp
chown root:servers /servers/samp
chmod 711 /servers/crmp
chown root:servers /servers/crmp
chmod 711 /servers/mta
chown root:servers /servers/mta
chmod 711 /servers/mc
chown root:servers /servers/mc
chmod -R 755 /path
chown root:servers /path
chmod -R 750 /copy
chown root:root /copy
chmod -R 750 /etc/proftpd
wget -O proftpd_sqldump $MIRROR/files/debian/proftpd/proftpd_sqldump.txt > /dev/null 2>&1
mysql -uroot -p$MYPASS -e "CREATE DATABASE ftp;"; > /dev/null 2>&1
mysql -uroot -p$MYPASS -e "CREATE USER 'ftp'@'localhost' IDENTIFIED BY '$MYPASS2';"; > /dev/null 2>&1
mysql -uroot -p$MYPASS -e "GRANT ALL PRIVILEGES ON ftp . * TO 'ftp'@'localhost';"; > /dev/null 2>&1
mysql -uroot -p$MYPASS ftp < proftpd_sqldump; > /dev/null 2>&1
rm -rf proftpd_sqldump > /dev/null 2>&1
sed -i 's/passwdfor/'$MYPASS'/g' /etc/proftpd/sql.conf > /dev/null 2>&1 && check
log_t "• Приступаем к установке ${red}Ioncube Loader${green} •"
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

echo "• Перезагружаем ${red}FTP, MySQL, Apache2${green} •"
service proftpd restart > /dev/null 2>&1 && check
echo "• Обновляем пакеты и веб сервисы •"
apt-get update > /dev/null 2>&1
service apache2 restart > /dev/null 2>&1
service mysql restart > /dev/null 2>&1
ln -s /usr/share/phpmyadmin /var/www/pma > /dev/null 2>&1 && check
  echo "• Удаляем папку ${red}html${green} [var/www/html] •"
  rm -r /var/www/html > /dev/null 2>&1 && check

log_t "• Завершаем установку ${red}BSPanel${green} на Debian 8 •"
  lines_1
  info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
  info_n "• Панель управления ${red}BSPanel ${YELLOW}установлена!"
  info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
  info_n "• Данные для входа в ${red}phpMyAdmin${YELLOW} и ${red}MySQL${green}:"
  info_n "• ${red}Логин${green}: ${YELLOW}root"
  info_n "• ${red}Пароль${green}: ${YELLOW}$MYPASS"
  info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
  info_n "• ${red}FTP пароль${YELLOW} от ${red}MySQL${green}: ${YELLOW}$MYPASS2"
  info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
  info_n "• Ссылка на ${red}BSPanel${green}: ${YELLOW}http://$DOMAIN/"
  info_n "• Ссылка на ${red}PhpMyAdmin${green}: ${YELLOW}http://$DOMAIN/phpmyadmin"
  info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
  info_n "• Данные для входа в панель управления${green}:"
  info_n "• ${red}Логин${green}: ${YELLOW}admin"
  info_n "• ${red}Пароль${green}: ${YELLOW}${new_pass}"
  info_n "• ${red}Ссылка${green}: ${YELLOW}http://$DOMAIN/acp"
  info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
  info_n "• ${red}Обязательно смените email и пароль после авторизации!"
  lines_1
Info
log_t "Спасибо, что установили ${red}BSPanel${green}, Не забудьте сохранить данные"
Info "• ${red}1${green} - Главное меню"
Info "• ${red}0${green} - Выйти"
Info
read -p "Пожалуйста, введите номер меню: " case
case $case in
  1) bspanelsh;;
  0) exit;;
esac
}
bspanelsh