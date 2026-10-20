#!/bin/bash

for service in nginx ssh cron
do
	if systemctl is-active --quiet "$service"
	then
		echo "$service is running"
	else
		echo " $service is NOT running"
	fi

done
