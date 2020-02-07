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
red=$(tput setf 4)
green=$(tput setf 2)
reset=$(tput sgr0)
toend=$(tput hpa $(tput cols))$(tput cub 6)
blue=$(tput setaf 4)
orange=$(tput setaf 3)
pink=$(tput setaf 5)
cyan=$(tput setaf 6)
echo "Скачиваем файлы"
apt-get update && apt-get upgrade > /dev/null 2>&1
apt-get install -y git > /dev/null 2>&1
git clone https://github.com/bspanel/install.git > /dev/null 2>&1
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
		1) install_check;;
		2) settings_location;;
		3) install_web;;
		4) mce_pass;;
		5) install_games;;
		0) exit;;
	esac
}
menu
