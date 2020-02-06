#!/bin/sh
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

echo "• Устанавливаем пакеты ${red}php5 php5-dev php5-curl php5-memcache php5-json php5-mysql php-pear${red} •"
apt-get install -y php5 php5-dev php5-curl php5-memcache php5-json php5-mysql php-pear > /dev/null 2>&1 && check
a2enmod php5