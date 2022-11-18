#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

version="v1.0.0"

# [[]] 表示高级字符串处理函数
if [[ $# != 2 ]]; then
	# -e 开启转义 \n 换行 退出状态 0 表示成功退出 非0表示失败出错退出
	echo -e "${red}错误: 必须传入参数！${plain}" && exit 1
fi

# start_install_bbr() {
# 	# clear
# 	echo 1
# }

make_config_file() {
	echo -e "${green}=====开始创建配置文件=====${plain}"
	case $1 in
		"jp")
        echo '{
  "log": {
        "level": "warn",
        "output": "/etc/realm/realm.log"
  },
  "dns": {
    "mode": "ipv4_and_ipv6",
    "protocol": "tcp_and_udp",
    "min_ttl": 0,
    "max_ttl": 60,
    "cache_size": 5
  },
  "network": {
    "use_udp": true,
    "zero_copy": true,
    "fast_open": true,
    "tcp_timeout": 300,
    "udp_timeout": 30,
    "send_proxy": false,
    "send_proxy_version": 2,
    "accept_proxy": false,
    "accept_proxy_timeout": 5
  },
  "endpoints": [
    {
      "listen":"0.0.0.0:31702",
      "remote":"t1.emovpn.buzz:443",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31710",
      "remote":"n20.emovpn.buzz:44333",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31714",
      "remote":"n22.emovpn.buzz:126",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31705",
      "remote":"n12.emovpn.buzz:80",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31706",
      "remote":"n16.emovpn.buzz:1254",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31707",
      "remote":"v6.emovpn.buzz:44333",
      "listen_transport": "",
      "remote_transport": ""
    }
  ]
}' > /etc/realm/realm.json
		;;
		"hk")
        echo '{
  "log": {
        "level": "warn",
        "output": "/etc/realm/realm.log"
  },
  "dns": {
    "mode": "ipv4_and_ipv6",
    "protocol": "tcp_and_udp",
    "min_ttl": 0,
    "max_ttl": 60,
    "cache_size": 5
  },
  "network": {
    "use_udp": true,
    "zero_copy": true,
    "fast_open": true,
    "tcp_timeout": 300,
    "udp_timeout": 30,
    "send_proxy": false,
    "send_proxy_version": 2,
    "accept_proxy": false,
    "accept_proxy_timeout": 5
  },
  "endpoints": [
    {
      "listen":"0.0.0.0:31702",
      "remote":"n9.emovpn.buzz:1289",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
        "listen":"0.0.0.0:31703",
        "remote":"n5.emovpn.buzz:1289",
        "listen_transport": "",
        "remote_transport": ""
    },
    {
        "listen":"0.0.0.0:31704",
        "remote":"n6.emovpn.buzz:1265",
        "listen_transport": "",
        "remote_transport": ""
    },
    {
        "listen":"0.0.0.0:31715",
        "remote":"n11.emovpn.buzz:1261",
        "listen_transport": "",
        "remote_transport": ""
    },
    {
        "listen":"0.0.0.0:31716",
        "remote":"n17.emovpn.buzz:1274",
        "listen_transport": "",
        "remote_transport": ""
    }
  ]
}' > /etc/realm/realm.json
        ;;
        "is")
        echo '{
  "log": {
        "level": "warn",
        "output": "/etc/realm/realm.log"
  },
  "dns": {
    "mode": "ipv4_and_ipv6",
    "protocol": "tcp_and_udp",
    "min_ttl": 0,
    "max_ttl": 60,
    "cache_size": 5
  },
  "network": {
    "use_udp": true,
    "zero_copy": true,
    "fast_open": true,
    "tcp_timeout": 300,
    "udp_timeout": 30,
    "send_proxy": false,
    "send_proxy_version": 2,
    "accept_proxy": false,
    "accept_proxy_timeout": 5
  },
  "endpoints": [
    {
      "listen":"0.0.0.0:31616",
      "remote":"n13.emovpn.buzz:1252",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31619",
      "remote":"n2.emovpn.buzz:1259",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31710",
      "remote":"n4.emovpn.buzz:1268",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31711",
      "remote":"n7.emovpn.buzz:1290",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31610",
      "remote":"n3.emovpn.buzz:1262",
      "listen_transport": "",
      "remote_transport": ""
    },
    {
      "listen":"0.0.0.0:31712",
      "remote":"n14.emovpn.buzz:1251",
      "listen_transport": "",
      "remote_transport": ""
    }
  ]
}' > /etc/realm/realm.json
        ;;
        # "is")
        # echo
        # ;;
		*)
        echo -e "${red}请输入正确的名字${plain}"
        exit 1
        ;;
	esac

	echo -e "${green}=====配置文件创建完成=====${plain}"
}

main() {
	apt -y update && apt install  -y curl wget vim zip sudo && mkdir /etc/realm && cd /etc/realm
	wget -O realm.tar.gz https://github.com/zhboner/realm/releases/download/v2.3.4/realm-x86_64-unknown-linux-gnu.tar.gz
	tar -xvf realm.tar.gz && chmod +x realm && rm -rf realm.tar.gz && cd

	echo -e "${green}软件更新完成${plain}"
	echo -e "${green}=====开始创建守护进程=====${plain}"

	echo "[Unit]
Description=realm
After=network.target
Wants=network.target

[Service]
Type=simple
StandardError=none
User=root
LimitAS=infinity
LimitCORE=infinity
LimitNOFILE=102400
LimitNPROC=102400
ExecStart=/etc/realm/realm -c /etc/realm/realm.json
ExecReload=/bin/kill -HUP 
ExecStop=/bin/kill 
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/realm.service

    echo -e "${green}=====守护进程创建成功=====${plain}"

    make_config_file $1

    systemctl daemon-reload && systemctl enable realm && service realm start && systemctl status realm --no-pager

    sleep 2

    systemctl status realm --no-pager
}

main $@