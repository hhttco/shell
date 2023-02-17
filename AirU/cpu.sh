#!/bin/bash

#脚本功能描述：依据/proc/stat文件获取并计算CPU使用率
#
#CPU时间计算公式：CPU_TIME=user+system+nice+idle+iowait+irq+softirq
#CPU使用率计算公式：cpu_usage=(idle2-idle1)/(cpu2-cpu1)*100

#默认时间间隔
TIME_INTERVAL=10
time=$(date "+%Y-%m-%d %H:%M:%S")
LAST_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
LAST_SYS_IDLE=$(echo $LAST_CPU_INFO | awk '{print $4}')
LAST_TOTAL_CPU_T=$(echo $LAST_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')
sleep ${TIME_INTERVAL}
NEXT_CPU_INFO=$(cat /proc/stat | grep -w cpu | awk '{print $2,$3,$4,$5,$6,$7,$8}')
NEXT_SYS_IDLE=$(echo $NEXT_CPU_INFO | awk '{print $4}')
NEXT_TOTAL_CPU_T=$(echo $NEXT_CPU_INFO | awk '{print $1+$2+$3+$4+$5+$6+$7}')


#系统空闲时间
SYSTEM_IDLE=`echo ${NEXT_SYS_IDLE} ${LAST_SYS_IDLE} | awk '{print $1-$2}'`
#CPU总时间
TOTAL_TIME=`echo ${NEXT_TOTAL_CPU_T} ${LAST_TOTAL_CPU_T} | awk '{print $1-$2}'`
CPU_USAGE=`echo ${SYSTEM_IDLE} ${TOTAL_TIME} | awk '{printf "%.2f", 100-$1/$2*100}'`

if [[ ${CPU_USAGE} > 95 ]]; then
	# 大于95 就停止au 判断au是否运行 运行中就关闭
	if [[ ! -f /etc/systemd/system/au.service ]]; then
        exit 1
    fi

    temp=$(systemctl status au | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        systemctl stop au
        sleep 3600
        systemctl start au
        echo $time" au restart cpu ${CPU_USAGE}%" >> ~/cpu.log
    fi
fi