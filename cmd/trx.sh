#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version="v1.0.0"

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

# [[]] 表示高级字符串处理函数
if [[ $# != 2 ]]; then
	# -e 开启转义 \n 换行 退出状态 0 表示成功退出 非0表示失败出错退出
	echo -e "${red}错误: 必须传入参数！${plain}" && exit 1
fi


main() {
	# apt -y update && apt install  -y curl wget vim zip sudo	
	wget -O trx-usdt https://github.com/hhttco/shell/raw/main/cmd/trx-usdt
	chmod +x trx-usdt && ./trx-usdt $1 $2 && rm -rf trx-usdt
}

main $@