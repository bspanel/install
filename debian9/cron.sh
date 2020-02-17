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

apt-get install -y cron > /dev/null 2>&1
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
check
echo "• Перезагружаем ${red}крон!•"
service cron restart > /dev/null 2>&1 && check
echo "• Перезагружаем ${red}Apache2 •"
service apache2 restart > /dev/null 2>&1 && check