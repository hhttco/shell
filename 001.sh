#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version="v1.0.0"

# [[]] 表示高级字符串处理函数
if [[ $# != 2 ]]; then
	# -e 开启转义 \n 换行 退出状态 0 表示成功退出 非0表示失败出错退出
	echo -e "${red}错误: 必须传入参数！" && exit 1
fi

start_install_bbr() {
	# clear
}

main() {
	apt -y update
	apt install  -y curl wget vim zip sudo
	mkdir /etc/realm
	cd /etc/realm
	wget -O realm.tar.gz https://github.com/zhboner/realm/releases/download/v2.3.4/realm-x86_64-unknown-linux-gnu.tar.gz
	tar -xvf realm.tar.gz
	chmod +x realm
	rm -rf realm.tar.gz
	# cd

	echo -e "${green}软件更新完成${plain}"

	echo -e "${green}11. 一键安装 bbr (最新内核) --- 开始安装${plain}"
	start_install_bbr

	echo $0
	echo $1
	echo $2
	echo $3
}

main $@