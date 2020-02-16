settings_location()
{
  echo "Locations settings started..."

  MYPASS=$(pwgen -cns -1 16)
  MYPASS2=$(pwgen -cns -1 16)

  echo "Add packages..."
  echo "deb http://ftp.ru.debian.org/debian/ $(lsb_release -sc) main" > /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ $(lsb_release -sc) main" >> /etc/apt/sources.list
  echo "deb http://security.debian.org/ $(lsb_release -sc)/updates main" >> /etc/apt/sources.list
  echo "deb-src http://security.debian.org/ $(lsb_release -sc)/updates main" >> /etc/apt/sources.list
  echo "deb http://ftp.ru.debian.org/debian/ $(lsb_release -sc)-updates main" >> /etc/apt/sources.list
  echo "deb-src http://ftp.ru.debian.org/debian/ $(lsb_release -sc)-updates main" >> /etc/apt/sources.list
  log_t "• Обновляем пакеты •"

  if [ "$(lsb_release -sc)" = "stretch" ]; then
    wget http://www.dotdeb.org/dotdeb.gpg
    apt-key add dotdeb.gpg
    rm dotdeb.gpg
    fi
  echo "Updating packages..."
  apt-get update
  apt-get upgrade -y
  echo mysql-server mysql-server/root_password select "$MYPASS" | debconf-set-selections
  echo mysql-server mysql-server/root_password_again select "$MYPASS" | debconf-set-selections
  apt-get install -y apt-utils pwgen dialog
  
  apt-get install -y apache2 php5.6 php5.6-dev cron unzip sudo nano php5.6-curl php5.6-memcache php5.6-json memcached mysql-server php5.6-mysql libapache2-mod-php5.6 php-pear
  log_t "• Включаем модуль ${red}Apache2${green} •"
  a2enmod php5.6
  service apache2 restart
  log_t "• Устанавливаем ${red}phpMyAdmin${green} •"
  echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYPASS" | debconf-set-selections
  echo "phpmyadmin phpmyadmin/mysql/app-pass password $MYPASS" |debconf-set-selections
  echo "phpmyadmin phpmyadmin/app-password-confirm password $MYPASS" | debconf-set-selections
  echo 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2' | debconf-set-selections
  apt-get install -y phpmyadmin
  log_t "• Устанавливаем ${red}mysql-server ${red}5${green}.${red}6${green} •"
  echo mysql-apt-config mysql-apt-config/select-server select mysql-5.6 | debconf-set-selections
  echo mysql-apt-config mysql-apt-config/select-product select Ok | debconf-set-selections
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.7-1_all.deb
  export DEBIAN_FRONTEND=noninteractive
  dpkg -i mysql-apt-config_0.8.7-1_all.deb 
    apt-get update
  apt-get --yes --force-yes install mysql-server
  sudo mysql_upgrade -u root -p$MYPASS --force --upgrade-system-tables
  service mysql restart
  rm mysql-apt-config_0.8.7-1_all.deb
  cd ~
  log_t "• Настраиваем время на сервере •"
  echo "Europe/Moscow" > /etc/timezone
  dpkg-reconfigure tzdata -f noninteractive
  sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5.6/cli/php.ini
    sudo sed -i -r 's~^;date\.timezone =$~date.timezone = "Europe/Moscow"~' /etc/php5.6/apache2/php.ini
  log_t "• Устанавливаем необходимые пакеты для ${red}серверной части​${green} •"
  apt-get install -y lsb-release
  apt-get install -y lib32stdc++6
  apt-get install -y libreadline5
  OS=$(lsb_release -s -i -c -r | xargs echo |sed 's; ;-;g' | grep Ubuntu)
  if [ "$OS" = "" ]; then
    sudo dpkg --add-architecture i386
    sudo apt-get update 
    sudo apt-get install -y ia32-libs
    sudo apt-get install -y gcc-multilib
  else
    cd /etc/apt/sources.list.d
    echo "deb http://old-releases.ubuntu.com/ubuntu/ raring main restricted universe multiverse" >ia32-libs-raring.list
    apt-get update
    apt-get install -y ia32-libs
    sudo apt-get install -y gcc-multilib
  fi
  apt-get install -y sudo screen htop nano tcpdump ethstatus ssh zip unzip mc qstat gdb lib32gcc1 nload ntpdate lsof
  apt-get install -y lib32z1
  log_t "• Приступаем к установке ${red}Java 8${green} •"
  wget javadl.sun.com/webapps/download/AutoDL?BundleId=106240 -O jre-linux.tar.gz ///
  tar xvfz jre-linux.tar.gz 
  mkdir /usr/lib/jvm 
  mv jre1.8.0_45 /usr/lib/jvm/jre1.8.0_45 
  update-alternatives --install /usr/bin/java java /usr/lib/jvm/jre1.8.0_45/bin/java 1 
  update-alternatives --config java
  log_t "• Обновляем пакеты •"  
  apt-get update  
  log_t "• Устанавливаем ${red}Java 8${green} •"
  sudo apt-get -y install oracle-java8-installer
  log_t "• Устанавливаем и настраиваем ${red}iptables${green} + ${red}rclocal${green} •"
  rm rclocal; wget -O rclocal $MIRROR/files/debian/rclocal/rclocal.txt
  sed -i '14d' /etc/rc.local
  cat rclocal >> /etc/rc.local
  touch /root/iptables_block
  echo "UseDNS no" >> /etc/ssh/sshd_config
  echo "UTC=no" >> /etc/default/rcS
  rm -rf rclocal
  log_t "• Устанавливаем и настраиваем ${red}iptables${green} + ${red}geoip${green} •"
  sudo apt-get --yes --force-yes install xtables-addons-common
  sudo apt-get --yes --force-yes install libtext-csv-xs-perl libxml-csv-perl libtext-csv-perl unzip
  sudo mkdir -p /usr/share/xt_geoip/
  mkdir geoiptmp
  cd geoiptmp
  /usr/lib/xtables-addons/xt_geoip_dl
  sudo /usr/lib/xtables-addons/xt_geoip_build GeoIPv6.csv GeoIPCountryWhois.csv -D /usr/share/xt_geoip
  cd ~
  rm -rf geoiptmp
  log_t "• Включаем ${red}Nginx${green} для модуля ${red}FastDL${green} •"
  rm nginx; wget -O nginx $MIRROR/files/debian/nginx/nginx.txt
  service apache2 stop
  apt-get install -y nginx
  mkdir -p /var/nginx/ 
  rm -rf /etc/nginx/nginx.conf
  mv nginx /etc/nginx/nginx.conf
  service nginx restart
  service apache2 start
  rm -rf nginx
  log_t "• Устанавливаем и настраиваем ${red}ProFTPd${green} •"
  rm proftpd; wget -O proftpd $MIRROR/files/debian/proftpd/proftpd.txt
  rm proftpd_modules; wget -O proftpd_modules $MIRROR/files/debian/proftpd/proftpd_modules.txt
  rm proftpd_sql; wget -O proftpd_sql $MIRROR/files/debian/proftpd/proftpd_sql.txt
  echo PURGE | debconf-communicate proftpd-basic
  echo proftpd-basic shared/proftpd/inetd_or_standalone select standalone | debconf-set-selections
  apt-get install -y proftpd-basic proftpd-mod-mysql
  rm -rf /etc/proftpd/proftpd.conf
  rm -rf /etc/proftpd/modules.conf
  rm -rf /etc/proftpd/sql.conf
  mv proftpd /etc/proftpd/proftpd.conf
  mv proftpd_modules /etc/proftpd/modules.conf
  mv proftpd_sql /etc/proftpd/sql.conf
  rm -rf proftpd
  rm -rf proftpd_modules
  rm -rf proftpd_sql
  mkdir -p /copy /servers /path/steam /var/nginx
  cd /path/steam && wget http://media.steampowered.com/client/steamcmd_linux.tar.gz
  tar xvfz steamcmd_linux.tar.gz && rm steamcmd_linux.tar.gz
  cd ~
  groupmod -g 998 `cat /etc/group | grep :1000 | awk -F":" '{print $1}'`
    groupadd -g 1000 servers;
  chmod 711 /servers
  chown root:servers /servers
  chmod -R 755 /path
  chown root:servers /path
  chmod -R 750 /copy
  chown root:root /copy
  chmod -R 750 /etc/proftpd
  rm proftpd_sqldump; wget -O proftpd_sqldump $MIRROR/files/debian/proftpd/proftpd_sqldump.txt
  mysql -uroot -p$MYPASS -e "CREATE DATABASE ftp;";
  mysql -uroot -p$MYPASS -e "CREATE USER 'ftp'@'localhost' IDENTIFIED BY '$MYPASS2';";#
  mysql -uroot -p$MYPASS -e "GRANT ALL PRIVILEGES ON ftp . * TO 'ftp'@'localhost';";
  mysql -uroot -p$MYPASS ftp < proftpd_sqldump;
  rm -rf proftpd_sqldump
  sed -i 's/passwdfor/'$MYPASS'/g' /etc/proftpd/sql.conf
  log_t "• Перезагружаем ${red}FTP MySQL${green} •"
  service proftpd restart
  log_t "• Обновляем пакеты и веб сервисы •"
  apt-get update
  service restart apache2
  service mysql restart
  log_t "• Завершаем настройку локации под ${red}BSPanel${green}  • •"
    lines_1
    info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
    info_n "• Локация успешно настроена под ${red}BSPanel"
    info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
    info_n "• Данные для входа в ${red}phpMyAdmin${YELLOW} и ${red}MySQL${green}:"
    info_n "• ${red}Логин${green}: ${YELLOW}root"
    info_n "• ${red}Пароль${green}: ${YELLOW}$MYPASS"
    info_n "• ${red}Пароль${YELLOW} от базы данных ${red}ftp${green}:${YELLOW}$MYPASS2"
    info_n "• Ссылка на ${red}PhpMyAdmin${green}:${YELLOW}http://$DOMAIN/phpmyadmin"
    info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
    info_n "• Данные адреса и пароля:"
    info_n "• Адрес${green}: ${YELLOW}$IPVDS${green}:${YELLOW}22"
    info_n "• Пароль${green}: ${YELLOW}$VPASS"
    info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
    info_n "• Данные от FTP:"
    info_n "• ${red}SQL_Логин${green}: ${YELLOW}root"
    info_n "• ${red}SQL_Пароль${green}: ${YELLOW}$MYPASS"
    info_n "• ${red}SQL_FileTP${green}: ${YELLOW}ftp"
    info_n "• ${red}SQL_Порт${green}: ${YELLOW}3306"
    info_n "••••••••••••••••••••••••••••••••••••••••••••••••••••••••••"
    info_n "• ${yellow}Скопируйте все данные и сохраните в файле .txt"
    info_n "• ${red}Данные вам пригодятся при добавлении Локации через Админ Панель"
    lines_1
  Info
  log_t "Спасибо, что настроили Локацию под ${red}BSPanel${green}, Не забудьте сохранить данные"
  Info "• ${red}1${green} - Установить игры"
  Info "• ${red}0${green} - Выйти из установщик"
  Info
  read -p "Пожалуйста, введите номер меню:" case
  case $case in
      1) install_games;;
    0) exit;;
  esac
}