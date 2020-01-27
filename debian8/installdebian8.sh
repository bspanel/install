#!/bin/sh

MIRROR='http://cdn.bspanel.ru'
IPVDS=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
VER=`cat /etc/issue.net | awk '{print $1$3}'`

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
bspanelsh()
{
red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)
clear
echo "${LIME_YELLOW}-------------------------------------------------------------------------------"
Info "Здравствуйте, данный скрипт поможет Вам установить ${red}BSPanel${blue} на Debian 8
Вам после установки, ни чего делать не надо.
Только надо установить MCE(для работы MySQL), и игры с нашего автоустановщика которые вам нужны!
Тарифы в панели уже созданы для всех игр и всех версий билдов.
Скрипт за Вас всё установить кроме игр!"
echo "${LIME_YELLOW}-------------------------------------------------------------------------------"
while true; do
read -p "${green}Вы уверены, что хотите установить полностью ${red}BSPanel${green}?(${red}Y${green}/${red}N${green}): " yn
case $yn in
  [Yy]* ) break;;
  [Nn]* ) menu;;
  * ) echo "Ответьте, пожалуйста ${red}Y${green} или ${red}N${green}.";;
esac
done
read -p "${CYAN}Пожалуйста, введите ${red}домен ${CYAN}или ${red}IP${green}: ${yellow}" DOMAIN
read -p "${CYAN}Введите пароль от root${green}: ${yellow}" VPASS
echo "• Начинаем установку ${red}BSPanel${green} •"
echo "• Обновляем пакеты •"
apt-get update > /dev/null 2>&1 && check
echo "• Устанавливаем пакеты ${red}apt-utils pwgen wget dialog sudo!${red} •"
apt-get install -y apt-utils pwgen wget dialog sudo > /dev/null 2>&1 && check
MYPASS=$(pwgen -cns -1 16)
MYPASS2=$(pwgen -cns -1 16)
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
echo "• Обновляем пакеты •"
apt-get update -y > /dev/null 2>&1
apt-get upgrade -y > /dev/null 2>&1 && check
echo mysql-server mysql-server/root_password select "$MYPASS" | debconf-set-selections
echo mysql-server mysql-server/root_password_again select "$MYPASS" | debconf-set-selections
echo "• Устанавливаем пакеты ${red}apache2 php5 php5-dev cron unzip sudo nano php5-curl php5-memcache php5-json memcached mysql-server php5-mysql libapache2-mod-php5 php-pear${red} •"
apt-get install -y apache2 php5 php5-dev cron unzip sudo nano php5-curl php5-memcache php5-json memcached mysql-server php5-mysql libapache2-mod-php5 php-pear > /dev/null 2>&1 && check
echo "• Включаем модуль ${red}Apache2${green} •"
a2enmod php5 > /dev/null 2>&1
service apache2 restart > /dev/null 2>&1 && check
echo "• Устанавливаем ${red}phpMyAdmin${green} •"
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections
echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
apt-get install -y phpmyadmin > /dev/null 2>&1 && check
echo  "• Устанавливаем ${red}mysql-server ${red}5${green}.${red}6${green} •"
echo mysql-apt-config mysql-apt-config/select-server select mysql-5.6 | debconf-set-selections
echo mysql-apt-config mysql-apt-config/select-product select Ok | debconf-set-selections
wget https://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb > /dev/null 2>&1
export DEBIAN_FRONTEND=noninteractive
dpkg -i mysql-apt-config_0.8.7-1_all.deb > /dev/null 2>&1
apt-get update > /dev/null 2>&1
apt-get --yes --force-yes install mysql-server > /dev/null 2>&1
sudo mysql_upgrade -u root -p$MYPASS --force --upgrade-system-tables > /dev/null 2>&1
service mysql restart > /dev/null 2>&1
rm mysql-apt-config_0.8.7-1_all.deb > /dev/null 2>&1
cd ~ > /dev/null 2>&1
sudo mysql_upgrade -u root -p$MYPASS --force --upgrade-system-tables > /dev/null 2>&1
service mysql restart > /dev/null 2>&1 && check
echo "• Устанавливаем библиотеку ${red}SSH2${green} •"
if [ "$OS" = "" ]; then
apt-get install -y curl php5-ssh2 > /dev/null 2>&1
else
apt-get install -y libssh2-php > /dev/null 2>&1
fi
check
echo "• Создаем хост в ${red}Apache2${green} - создание файлов виртуальных хостов •"
mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/.000-default.conf
FILE='/etc/apache2/sites-available/000-default.conf'
  echo "<VirtualHost *:80>">$FILE
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

echo "• Включаем модуль ${red}mod_rewrite${green} для ${red}Apache2${green} •"
a2enmod rewrite > /dev/null 2>&1 && check
echo "• Перезагружаем ${red}Apache2${green} •"
service apache2 restart	> /dev/null 2>&1 && check

DIR="/var/www"
CRONKEY=$(pwgen -cns -1 6)
CRONPANEL="/etc/crontab"

echo "• Добавляем ${red}сron задания${green} •"

sed -i "s/320/0/g" $CRONPANEL
echo "">>$CRONPANEL
echo "*/2 * * * * screen -dmS scan_servers bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads scan_servers'">>$CRONPANEL
echo "*/5 * * * * screen -dmS scan_servers_load bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads scan_servers_load'">>$CRONPANEL
echo "*/5 * * * * screen -dmS scan_servers_route bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads scan_servers_route'">>$CRONPANEL
echo "* * * * * screen -dmS scan_servers_down bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads scan_servers_down'">>$CRONPANEL
echo "*/10 * * * * screen -dmS notice_help bash -c 'cd ${DIR} && php cron.php ${CRONKEY} notice_help'">>$CRONPANEL
echo "*/15 * * * * screen -dmS scan_servers_stop bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads scan_servers_stop'">>$CRONPANEL
echo "*/15 * * * * screen -dmS scan_servers_copy bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads scan_servers_copy'">>$CRONPANEL
echo "*/30 * * * * screen -dmS notice_server_overdue bash -c 'cd ${DIR} && php cron.php ${CRONKEY} notice_server_overdue'">>$CRONPANEL
echo "*/30 * * * * screen -dmS preparing_web_delete bash -c 'cd ${DIR} && php cron.php ${CRONKEY} preparing_web_delete'">>$CRONPANEL
echo "0 * * * * screen -dmS scan_servers_admins bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads scan_servers_admins'">>$CRONPANEL
echo "* * * * * screen -dmS control_delete bash -c 'cd ${DIR} && php cron.php ${CRONKEY} control_delete'">>$CRONPANEL
echo "* * * * * screen -dmS control_install bash -c 'cd ${DIR} && php cron.php ${CRONKEY} control_install'">>$CRONPANEL
echo "*/2 * * * * screen -dmS scan_control bash -c 'cd ${DIR} && php cron.php ${CRONKEY} scan_control'">>$CRONPANEL
echo "*/2 * * * * screen -dmS control_scan_servers bash -c 'cd ${DIR} && php cron.php ${CRONKEY} control_threads control_scan_servers'">>$CRONPANEL
echo "*/5 * * * * screen -dmS control_scan_servers_route bash -c 'cd ${DIR} && php cron.php ${CRONKEY} control_threads control_scan_servers_route'">>$CRONPANEL
echo "* * * * * screen -dmS control_scan_servers_down bash -c 'cd ${DIR} && php cron.php ${CRONKEY} control_threads control_scan_servers_down'">>$CRONPANEL
echo "0 * * * * screen -dmS control_scan_servers_admins bash -c 'cd ${DIR} && php cron.php ${CRONKEY} control_threads control_scan_servers_admins'">>$CRONPANEL
echo "*/15 * * * * screen -dmS control_scan_servers_copy bash -c 'cd ${DIR} && php cron.php ${CRONKEY} control_threads control_scan_servers_copy'">>$CRONPANEL
echo "0 0 * * * screen -dmS graph_servers_day bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads graph_servers_day'">>$CRONPANEL
echo "0 * * * * screen -dmS graph_servers_hour bash -c 'cd ${DIR} && php cron.php ${CRONKEY} threads graph_servers_hour'">>$CRONPANEL
echo "#">>$CRONPANEL
crontab -u root /etc/crontab

echo "• Перезагружаем ${red}крон!•"
service cron restart > /dev/null 2>&1 && check
echo "• Перезагружаем ${red}Apache2 •"
service apache2 restart > /dev/null 2>&1 && check
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
echo "• Настраиваем время на сервере •"
echo "Europe/Moscow" > /etc/timezone
dpkg-reconfigure tzdata -f noninteractive > /dev/null 2>&1
sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5/cli/php.ini > /dev/null 2>&1
sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5/apache2/php.ini > /dev/null 2>&1 && check
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