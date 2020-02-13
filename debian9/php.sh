#!/bin/sh
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

echo "• Устанавливаем пакеты ${red}php5 php5-dev php5-curl php5-memcache php5-json php5-mysql php-pear${red} •"
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - > /dev/null 2>&1
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list > /dev/null 2>&1
apt-get update > /dev/null 2>&1
echo "• Устанавливаем пакеты! •"
apt-get install -y php5.6 > /dev/null 2>&1
sudo apt-get install -y php5.6-cli php5.6-common php5.6-curl php5.6-mbstring php5.6-mysql php5.6-xml > /dev/null 2>&1
apt-get install -y php-memcache > /dev/null 2>&1
apt-get install -y php-memcached > /dev/null 2>&1
apt-get install -y memcached > /dev/null 2>&1
apt-get install php5.6-gd > /dev/null 2>&1 && check