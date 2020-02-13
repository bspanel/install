#!/bin/sh
. /root/install/debian8/config
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