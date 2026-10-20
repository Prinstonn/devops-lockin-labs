#!/bin/bash

if [ -z "$1" ]
then
	echo "ERROR: Please provide at least one service."
        echo "Usage: $0 <service1> <service2> ...."
        exit 1
fi


for service in "$@"
do
	echo "Checking $service..."

	if systemctl is-active --quiet "$service"
	then
		 echo "$service is running"
	else
		echo "$service NOT running"
	fi

done
