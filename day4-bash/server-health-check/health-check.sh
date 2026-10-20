#!/bin/bash

# ==========================================
# DevOps Server Health Check
# Day 4 - DevOps Lock-In
# ==========================================


echo "=========================================="
echo "       SERVER HEALTH CHECK"
echo "=========================================="
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Date: $(date)"
echo "=========================================="


check_disk() {
	local threshold=80
	local usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

	echo
	echo "_____ DISK CHECK _____"
	echo "Disk usage: ${usage}%"


	if [ "$usage" -ge "$threshold" ]
	then
		echo "WARNING: Disk usage is above ${threshold}%"
		return 1
	else
		echo "OK: Disk usage is healthy"
		return 0
	fi
}


check_memory() {

    local threshold=80
    local usage=$(free | awk '/^Mem:/ {printf "%.0f\n", ($2-$7)/$2 * 100}')

    echo
    echo "----- MEMORY CHECK -----"
    echo "Memory usage: ${usage}%"

    if [ "$usage" -ge "$threshold" ]
    then
        echo "WARNING: Memory usage is above ${threshold}%"
        return 1
    else
        echo "OK: Memory usage is healthy"
        return 0
    fi
}

check_load() {

    local load=$(awk '{print $1}' /proc/loadavg)
    local cores=$(nproc)

    echo
    echo "----- SYSTEM LOAD CHECK -----"
    echo "1-minute load average: $load"
    echo "CPU cores: $cores"

    if awk "BEGIN {exit !($load >= $cores)}"
    then
        echo "WARNING: System load is high"
        return 1
    else
        echo "OK: System load is healthy"
        return 0
    fi
}

check_service() {

        local service="$1"


        echo "----- SERVICE CHECK: $service -----"


        if systemctl is-active --quiet "$service"
        then

                echo "OK: $service is running"
                return 0
        else
                echo "WARNING: $service is NOT running"
                return 1
        fi
}


check_network() {
	local target="8.8.8.8"

	echo
	echo "----- NETWORK CHECK -----"
	echo "Testing connectivity to $target..."
	

	if ping -c 1 -W 2 "$target" > /dev/null 2>&1
	then
		echo "OK: Network connectivity is working"
		return 0
	else
		echo "WARNING: Network connectivity failed"
		return 1
	fi
}

check_http() {
	local url="http://localhost"

	local status=$(curl -s -o /dev/null -w "%{http_code}" "$url")

	echo
	echo "----- HTTP CHECK -----"

	if [ "$status" -eq 200 ] 
	then
		echo "OK: HTTP endpoint returned 200"
		return 0
	elif [ "$status" -eq 000 ]
	then
		echo "WARNING: HTTP endpoint returned 000"
		return 1
	else
		echo "WARNING: HTTP endpoint returned $status"
		return 1
	fi
}

overall_status=0

check_disk || overall_status=1
check_memory|| overall_status=1
check_load || overall_status=1


check_service nginx|| overall_status=1
check_service ssh || overall_status=1
check_service cron || overall_status=1

check_network || overall_status=1
check_http || overall_status=1


echo
echo "========================================"

if [ "$overall_status" -eq 0 ]
then
	echo "OVERALL STATUS: HEALTHY"
else
	echo "OVERALL STATUS: UNHEALTHY"
fi
echo "========================================"

exit "$overall_status"
