#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

# [[]] 表示高级字符串处理函数
if [[ $# != 3 ]]; then
    # -e 开启转义 \n 换行 退出状态 0 表示成功退出 非0表示失败出错退出
    echo -e "${red}错误: 必须传入参数！${plain}" && exit 1
fi

get_eth() {
	# Install bc based on system package manager
	if !(command -v bc > /dev/null); then
		if command -v apt-get > /dev/null; then
            apt-get update && apt-get install -y bc
        elif command -v yum > /dev/null; then
            yum update -y && yum install -y bc
        else
            echo "Could not install bc. Please install it manually."
            exit 1
        fi
	fi

    local interfaces=$(ip -o link show | \
        awk -F': ' '$2 !~ /^((lo|docker|veth|br-|virbr|tun|vnet|wg|vmbr|dummy|gre|sit|vlan|lxc|lxd|warp|tap))/{print $2}' | \
        grep -v '@')

    local interface_count=$(echo "$interfaces" | wc -l)

    # 格式化流量大小的函数
    format_bytes() {
        local bytes=$1
        if [ $bytes -lt 1024 ]; then
            echo "${bytes} B"
        elif [ $bytes -lt 1048576 ]; then # 1024*1024
            echo "$(echo "scale=2; $bytes/1024" | bc) KB"
        elif [ $bytes -lt 1048576 ]; then # 1024*1024
            echo "$(echo "scale=2; $bytes/1024" | bc) KB"
        elif [ $bytes -lt 1073741824 ]; then # 1024*1024*1024
            echo "$(echo "scale=2; $bytes/1024/1024" | bc) MB"
        elif [ $bytes -lt 1099511627776 ]; then # 1024*1024*1024*1024
            echo "$(echo "scale=2; $bytes/1024/1024/1024" | bc) GB"
        else
            echo "$(echo "scale=2; $bytes/1024/1024/1024/1024" | bc) TB"
        fi
    }

    # 显示网卡流量的函数
    show_interface_traffic() {
        local interface=$1
        if [ -d "/sys/class/net/$interface" ]; then
            local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes)
            local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes)
            echo "   ↓ Received: $(format_bytes $rx_bytes)"
            echo "   ↑ Sent: $(format_bytes $tx_bytes)"
        else
            echo "   无法读取流量信息"
        fi
    }

    # 如果没有找到合适的接口或有多个接口时显示所有可用接口
    echo "所有可用的网卡接口:" >&2
    echo "------------------------" >&2
    local i=1
    while read -r interface; do
        echo "$i) $interface" >&2
        show_interface_traffic "$interface" >&2
        i=$((i+1))
    done < <(ip -o link show | grep -v "lo:" | awk -F': ' '{print $2}')
    echo "------------------------" >&2
   
    while true; do
        read -p "请选择网卡，如上方显示异常或没有需要的网卡，请直接填入网卡名: " selection
       
        # 检查是否为数字
        if [[ "$selection" =~ ^[0-9]+$ ]]; then
            # 如果是数字，检查是否在有效范围内
            selected_interface=$(ip -o link show | grep -v "lo:" | sed -n "${selection}p" | awk -F': ' '{print $2}')
            if [ -n "$selected_interface" ]; then
                echo "已选择网卡: $selected_interface" >&2
                echo "$selected_interface"
                break
            else
                echo "无效的选择，请重新输入" >&2
                continue
            fi
        else
            # 直接使用输入的网卡名
            echo "已选择网卡: $selection" >&2
            echo "$selection"
            break
        fi
    done
}

install_client() {
    net_name=$(get_eth $@)
    auth_secret="$1"
    url="$2"
    client_name="$3"

    mkdir -p /etc/my_servers/ && cd /etc/my_servers/
    wget -O client https://github.com/hhttco/myServers/releases/latest/download/my_servers_client_v1.0.0-amd64
    chmod 777 client

    # Create systemd service file
cat > /etc/systemd/system/my_servers_client.service << 'EOF'
[Unit]
Description=My Servers Client Deamon
After=network.target nss-lookup.target
Wants=network.target

[Service]
User=root
Group=root
Type=simple
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=102400
WorkingDirectory=/etc/my_servers/
ExecStart=/etc/my_servers/client
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
EOF

# Create client configuration
    cat > /etc/my_servers/client.json << EOF
{
  "auth_secret": "${auth_secret}",
  "url": "${url}",
  "net_name": "${net_name}",
  "name": "${client_name}"
}
EOF

    # Set proper permissions
    chmod 644 /etc/my_servers/client.json
    chmod 644 /etc/systemd/system/my_servers_client.service

    # Reload systemd and enable service
    systemctl daemon-reload
    systemctl enable my_servers_client.service
    systemctl start my_servers_client.service

    echo -e "${green}客户端安装完成...${plain}"
}

main() {
    # systemctl stop my_servers_client

    install_client $@

    # echo "OK"
}

main $@