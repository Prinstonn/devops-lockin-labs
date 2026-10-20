#!/bin/bash

if [ -z "$1" ]
then
	echo "ERROR: service(s) missing. Input at least one service."
	echo "Usage: $0 <service1> <service2> ..."
	exit 1
fi

check_service() {

	local service="$1"


	echo "Checking $service..."


	if systemctl is-active --quiet "$service"
	then

		echo "$service is running"
		return 0
	else
		echo "$service is NOT running"
		return 1
	fi
}

for service in "$@"
do
	check_service "$service"
done
