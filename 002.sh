#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version="v1.0.0"

# [[]] 表示高级字符串处理函数 pUrl 地址 nKey token nIds 节点ID nTids 节点类型 0. VMess 1. ShadowSocks 2. Trojan 
if [[ $# != 4 ]]; then
    # -e 开启转义 \n 换行 退出状态 0 表示成功退出 非0表示失败出错退出
    echo -e "${red}错误: 缺少必要参数！${plain}"
    echo -e "${yellow}1.主机地址${plain}"
    echo -e "${yellow}2.token${plain}"
    echo -e "${yellow}3.节点IDS 多个英文逗号分隔 ${plain}"
    echo -e "${yellow}4.节点类型 和IDS一一对应 0.VMess 1.ShadowSocks 2.Trojan ${plain}"
    exit 1
fi

main() {
    bash <(curl -Ls https://raw.githubusercontent.com/hhttco/shell/main/AirU/AirU.sh)
}

main $@