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

	if [ "$addr" == "" ]; then
		echo -e "${red}地址输入不正确${plain}"
		show_menu
	else
		wget -O trx-usdt https://github.com/hhttco/shell/raw/main/cmd/trx-usdt
		chmod +x trx-usdt && echo -e "${green} 查询地址: ${addr} ${plain}" && echo && ./trx-usdt U ${addr} && rm -rf trx-usdt

		echo && echo -e "${green} 脚本运行完成 ${plain}" && exit 0
	fi
}

Transfer() {
	echo -e "
  ${green}trx-usdt 脚本，${plain}${red}不适用于docker${plain}
--- 请选择转账类型 ---
  ${green}0.${plain} 退出脚本
————————————————
  ${green}1.${plain} TRX
  ${green}2.${plain} USDT
————————————————
  ${green}3.${plain} 其他
 "
	read -p "请输入选择 [0-3]: " num

	case "${num}" in
		0) exit 0
		;;
		1) Transfer_trx
		;;
		2) Transfer_usdt
		;;
		3) search_balance
		;;
		*) echo -e "${red}请输入正确的数字 [0-3]${plain}"
		;;
	esac
}

Transfer_trx() {
	read -p "请输入转账金额: " money
	echo
	read -p "请输入转账地址: " addr
	echo
	read -p "请输入转账私钥: " secretKey
	echo
	read -p "请输入收款地址: " toAddr

	wget -O trx-usdt https://github.com/hhttco/shell/raw/main/cmd/trx-usdt
	chmod +x trx-usdt && echo -e "${green} 转账地址: ${addr} ${plain}" && echo
	./trx-usdt TT ${money} ${addr} ${toAddr} ${secretKey} && rm -rf trx-usdt

	echo && echo -e "${green} 脚本运行完成 ${plain}" && exit 0
}

Transfer_usdt() {
	read -p "请输入转账金额: " money
	echo
	read -p "请输入转账地址: " addr
	echo
	read -p "请输入转账私钥: " secretKey
	echo
	read -p "请输入收款地址: " toAddr
	echo
	read -p "请输入合约地址: " seedAddr

	wget -O trx-usdt https://github.com/hhttco/shell/raw/main/cmd/trx-usdt
	chmod +x trx-usdt && echo -e "${green} 转账地址: ${addr} ${plain}" && echo
	./trx-usdt T ${money} ${addr} ${toAddr} ${seedAddr} ${secretKey} && rm -rf trx-usdt

	echo && echo -e "${green} 脚本运行完成 ${plain}" && exit 0
}

show_menu() {
	echo -e "
  ${green}trx-usdt 脚本，${plain}${red}不适用于docker${plain}
--- 菜单内容 ---
  ${green}0.${plain} 退出脚本
————————————————
  ${green}1.${plain} 查询
  ${green}2.${plain} 转账
————————————————
  ${green}3.${plain} 其他
 "
	read -p "请输入选择 [0-3]: " num

	case "${num}" in
		0) exit 0
		;;
		1) search_balance
		;;
		2) Transfer
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

		echo && echo -e "${green} 脚本运行完成 ${plain}" && exit 0
	fi

	show_menu $@
}

main $@
