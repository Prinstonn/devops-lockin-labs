#!/bin/bash

path=$1

if [ -z "$1" ] 
then
	echo "ERROR: Please provide a path."
	echo "Usage: $0 <path>"
	exit 1
fi

if [ -e "$1" ]
then
	echo "$1 exists."
else
	echo "$1 does NOT exists."
fi
	
