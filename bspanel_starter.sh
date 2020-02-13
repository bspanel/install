#!/bin/sh

MIRROR='http://cdn.bspanel.ru'
IPVDS=$(echo "${SSH_CONNECTION}" | awk '{print $3}')
VER=`cat /etc/issue.net | awk '{print $1$3}'`

infomenu()
{
	Info "${green}|--------------- | ${CYAN}Добро пожаловать, в установочное меню ${red}BSPanel${green} (${orange}тариф Starter Pack${green}) | ---------------|"
}
infomenu2()
{
	Info "${green}|------------------------------------------------------------------------------------------------------|"
}
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
install_check()
{
	if [ -f "/root/install" ]; then
	menu
	else
	echo "${green}|---------------Скачиваем необходимые файлы---------------${reset}"
	apt-get update > /dev/null 2>&1
	apt-get upgrade > /dev/null 2>&1
	apt-get install -y git > /dev/null 2>&1
	git clone https://github.com/bspanel/install.git > /dev/null 2>&1
	menu
	fi
}
check_os()
{
if [ -f "/etc/debian_version" ]; then
	OS=`cat /etc/issue.net | awk '{print $1$3}'`
	echo "Detected OS Version: "$OS
fi
if [ "$OS" = "Debian8" ]; then
  echo "${green}|---------------Найдена OS: DEBIAN 8---------------${reset}"
  cd /root/install/debian8/
  sh installdebian8.sh
fi
if [ "$OS" = "Debian7" ]; then
  echo "${green}|---------------Поддержка DEBIAN 7 не доступна---------------${reset}"
  exit
fi
if [ "$OS" = "Debian9" ]; then
 echo "${green}|---------------Подддержка DEBIAN 9 временно не доступна---------------${reset}"
 cd /root/install/debian9/
sh installdebian9.sh
fi
}
menu()
{
	clear
	infomenu
	Info "• ${red}1${green} - Установить ${red}BSPanel${green} •"
	Info "• ${red}2${green} - Настройка локации под ${red}BSPanel${green} •"
	Info "• ${red}3${green} - Меню ${red}установки WEB модулей${green}"
	Info "• ${red}4${green} - Меню установки ${red}бесплатных шаблонов${green} •"
	Info "• ${red}5${green} - Меню установки ${red}игр${green} •"
	Info "• ${red}0${green} - Выйти •"
	infomenu2
	read -p "${cyan}Пожалуйста, введите пункт меню: " case
	case $case in
		1) check_os;;
		2) settings_location;;
		3) install_web;;
		4) mce_pass;;
		5) install_games;;
		0) exit;;
	esac
}
install_check
