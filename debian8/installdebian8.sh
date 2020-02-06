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
sed -i "s/pass/${VPASS}/g" /root/install/debian8/config
echo "• Начинаем установку ${red}BSPanel${green} •"
echo "• Обновляем пакеты •"
apt-get update > /dev/null 2>&1 && check
echo "• Устанавливаем необходимые пакеты для ${red}серверной части​${green} •"
apt-get install -y apt-utils pwgen wget dialog sudo unzip nano memcached git lsb-release lib32stdc++6 sudo libreadline5 screen htop nano tcpdump lib32z1 ethstatus ssh zip unzip mc qstat gdb lib32gcc1 nload ntpdate lsof > /dev/null 2>&1 && check
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

###################################PHP######################################################################
sh /root/install/debian8/php.sh
###################################PHP######################################################################

###################################Apache2##################################################################
sh /root/install/debian8/apache.sh
###################################Apache2##################################################################

###################################Nginx####################################################################
sh /root/install/debian8/nginx.sh
###################################Nginx####################################################################

###################################MYSQL####################################################################
sh /root/install/debian8/mysql.sh
###################################MYSQl####################################################################

###################################TIME####################################################################
sh /root/install/debian8/time.sh
###################################TIME####################################################################
echo "• Устанавливаем библиотеку ${red}SSH2${green} •"
if [ "$OS" = "" ]; then
apt-get install -y curl php5-ssh2 > /dev/null 2>&1
else
apt-get install -y libssh2-php > /dev/null 2>&1
fi
check
###################################CRON#####################################################################
sh /root/install/debian8/cron.sh
###################################CRON#####################################################################

###################################IONCUBE##################################################################
sh /root/install/debian8/ioncube.sh
###################################IONCUBE##################################################################

###################################DDOS PROTECT##################################################################
sh /root/install/debian8/ddos.sh
###################################DDOS PROTECT##################################################################
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
###################################java##################################################################
sh /root/install/debian8/java.sh
###################################java##################################################################

###################################iptables##################################################################
sh /root/install/debian8/iptables.sh
###################################iptables##################################################################
#echo "• Включаем ${red}Nginx${green} для модуля ${red}FastDL${green} •"
#wget -O nginx $MIRROR/files/debian/nginx/nginx.txt > /dev/null 2>&1
#service apache2 stop > /dev/null 2>&1
#apt-get install -y nginx > /dev/null 2>&1
#mkdir -p /var/nginx/ > /dev/null 2>&1
#rm -rf /etc/nginx/nginx.conf > /dev/null 2>&1
#mv nginx /etc/nginx/nginx.conf > /dev/null 2>&1
#service nginx restart > /dev/null 2>&1
#service apache2 start > /dev/null 2>&1
#rm -rf nginx > /dev/null 2>&1 && check

###################################proftpd##################################################################
sh /root/install/debian8/proftpd.sh
###################################proftpd##################################################################
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