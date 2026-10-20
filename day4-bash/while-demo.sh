#!/bin/bash

count=1

while [ "$count" -le 5 ]
do
	echo "Health check number: $count"
	count=$((count + 1))
done
