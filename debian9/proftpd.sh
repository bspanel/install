#!/bin/sh
. /root/install/debian9/config
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
echo "• Настраиваем ${red}ProFTPd${green} •"
mkdir /root/save
cp /etc/apt/sources.list /root/save/
rm -r /etc/apt/sources.list
cp /root/install/debian9/sources.list /etc/apt/
apt-get update
wget -O proftpd $MIRROR/files/debian/proftpd/proftpd.txt > /dev/null 2>&1
wget -O proftpd_modules $MIRROR/files/debian/proftpd/proftpd_modules.txt > /dev/null 2>&1
echo PURGE | debconf-communicate proftpd-basic > /dev/null 2>&1
echo proftpd-basic shared/proftpd/inetd_or_standalone select standalone | debconf-set-selections
apt-get install --allow-unauthenticated -y proftpd-basic proftpd-mod-mysql > /dev/null 2>&1
rm -rf /etc/proftpd/proftpd.conf > /dev/null 2>&1
rm -rf /etc/proftpd/modules.conf > /dev/null 2>&1
rm -rf /etc/proftpd/sql.conf > /dev/null 2>&1
mv proftpd /etc/proftpd/proftpd.conf > /dev/null 2>&1
mv proftpd_modules /etc/proftpd/modules.conf > /dev/null 2>&1
rm -rf proftpd > /dev/null 2>&1
rm -rf proftpd_modules > /dev/null 2>&1
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
rm -r /etc/apt/sources.list
cp /root/save/sources.list /etc/apt/
apt-get update > /dev/null 2>&1
check