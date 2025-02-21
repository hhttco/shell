#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

auth_secret=""
go_port=""
hook_token=""
vue_domain=""
go_domain=""

[[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 必须使用root用户运行此脚本！\n" && exit 1

# read parameter
read_parameter() {
	# Get user input
    read -p "Enter auth_secret: " auth_secret
    read -p "Enter listen port (default 9527): " go_port
    go_port=${go_port:-"9527"}
    read -p "Enter hook_token: " hook_token

    read -p "请设置前端域名（已解析到此服务器的域名，例如：vue.example.com）: " vue_domain
    read -p "请设置后端域名（已解析到此服务器的域名，例如：go.example.com）: " go_domain

    if ! [[ "$go_port" =~ ^[0-9]+$ ]] || [ "$go_port" -lt 1 ] || [ "$go_port" -gt 65535 ]; then
        echo -e "${red}错误：无效的端口号${plain}" && exit 1
    fi
}

# caddy
install_caddy() {
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        echo -e "${green}检测到 Debian/Ubuntu 系统${plain}"
        apt-get update && apt-get install -y wget unzip curl ufw debian-keyring debian-archive-keyring apt-transport-https
    
        # install Caddy
        if ! command -v caddy &> /dev/null; then
            echo -e "${green}正在安装 Caddy...${plain}"
            curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/setup.deb.sh' | bash
            apt-get install caddy
        fi

    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        echo -e "${green}检测到 CentOS/RHEL 系统${plain}"
        yum install -y wget unzip curl yum-utils
    
        # install Caddy
        if ! command -v caddy &> /dev/null; then
            echo -e "${green}正在安装 Caddy...${plain}"
            yum install -y 'dnf-command(copr)'
            yum copr enable -y @caddy/caddy
            yum install -y caddy
        fi
    else
        echo -e "${red}不支持的操作系统！${plain}" && exit 1
    fi
}

# master go
install_master() {
    mkdir -p /etc/my_servers/ && cd /etc/my_servers/
    wget -O my_servers https://github.com/hhttco/myServers/releases/latest/download/my_servers_v1.0.0-amd64
    chmod 777 my_servers

    # Create service file
    cat > /etc/systemd/system/my_servers.service <<EOF
[Unit]
Description=My Servers Deamon
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
ExecStart=/etc/my_servers/my_servers
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    # Create config file
    cat > /etc/my_servers/config.json <<EOF
{
  "auth_secret": "${auth_secret}",
  "listen": ":${go_port}",
  "hook_uri": "/hook",
  "update_uri": "/my_tz",
  "web_uri": "/ws",
  "hook_token": "${hook_token}"
}
EOF

    chmod 644 /etc/my_servers/config.json
    chmod 644 /etc/systemd/system/my_servers.service

    # Start service
    systemctl daemon-reload
    systemctl enable my_servers.service
    systemctl start my_servers.service

    echo -e "${green}后端安装完成...${plain}"
    sleep 5
}

# vue
install_vue() {
    mkdir -p /etc/my_servers/vue && cd /etc/my_servers/vue
    wget -O vue.zip https://github.com/hhttco/myServers/releases/latest/download/my_servers_vue_v1.0.0.zip
    unzip -o vue.zip
    rm vue.zip

    cat > /etc/my_servers/vue/config.json <<EOF
{
  "socket": "wss://${go_domain}/ws",
  "apiURL": "https://${go_domain}"
}
EOF

    cat > /etc/caddy/Caddyfile <<EOF
${vue_domain} {
    root * /etc/my_servers/vue
    file_server
    encode gzip
    try_files {path} /index.html
}

${go_domain} {
    reverse_proxy localhost:${go_port}
}
EOF

    # 设置适当的权限
    if [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        chown -R caddy:caddy /etc/my_servers/vue
    else
        chown -R www-data:www-data /etc/my_servers/vue
    fi
    chmod -R 755 /etc/my_servers/vue

    # 配置防火墙
    if command -v firewall-cmd &> /dev/null; then
        # CentOS/RHEL 防火墙配置
        firewall-cmd --permanent --zone=public --add-service=http
        firewall-cmd --permanent --zone=public --add-service=https
        firewall-cmd --reload
    elif command -v ufw &> /dev/null; then
        # Ubuntu/Debian 防火墙配置
        ufw allow 80/tcp
        ufw allow 443/tcp
    fi

    # 启动并启用 Caddy 服务
    echo -e "${green}正在启动服务...${plain}"
    sleep 5
    systemctl restart caddy
    systemctl enable caddy

    echo -e "${green}安装完成！${plain}"
    echo -e "${green}前端已部署到 https://${vue_domain}${plain}"
    echo -e "${green}后端已配置到 https://${go_domain}，反向代理到本地端口 ${go_port}${plain}"
}

main() {
    # read parameter
    read_parameter

	# caddy
	install_caddy

    # master go
	install_master

	# vue
	install_vue

	# echo "OK"
}

main