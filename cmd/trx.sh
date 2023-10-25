#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version="v1.0.0"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

# [[]] 表示高级字符串处理函数
# if [[ $# != 2 ]]; then
	# -e 开启转义 \n 换行 退出状态 0 表示成功退出 非0表示失败出错退出
	# echo -e "${red}错误: 必须传入参数！${plain}" && exit 1
# fi

search_balance() {
	read -p "请输入要查询的地址: " addr

	if [[ $# == 0 ]]; then
		echo -e "${red}地址输入不正确${plain}"
		show_menu
	fi

	wget -O trx-usdt https://github.com/hhttco/shell/raw/main/cmd/trx-usdt
	chmod +x trx-usdt && echo -e "${green} 查询地址: ${addr} ${plain}" && ./trx-usdt U ${addr} && rm -rf trx-usdt

	echo -e "${green} 脚本运行完成 ${plain}" && exit 0
}

show_menu() {
	echo -e "
  ${green}trx-usdt 脚本，${plain}${red}不适用于docker${plain}
--- 菜单内容 ---
  ${green}0.${plain} 退出脚本
————————————————
  ${green}1.${plain} 查询
  ${green}2.${plain} 转账
  ${green}3.${plain} 其他
————————————————
  ${green}3.${plain} 其他
 "
	read -p "请输入选择 [0-3]: " num

	case "${num}" in
		0) exit 0
		;;
		1) search_balance $@
		;;
		2) search_balance
		;;
		3) search_balance
		;;
		*) echo -e "${red}请输入正确的数字 [0-3]${plain}"
		;;
	esac
}

main() {
	if [[ $# == 2 ]]; then
		wget -O trx-usdt https://github.com/hhttco/shell/raw/main/cmd/trx-usdt
		chmod +x trx-usdt && ./trx-usdt $1 $2 && rm -rf trx-usdt

		echo -e "${green} 脚本运行完成 ${plain}" && exit 0
	fi

	show_menu $@
}

main $@
