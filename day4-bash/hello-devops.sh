#!/bin/bash

# Day 4 - Bash Scripting
# Learning variables and command substitution

name="Prinston"
role="DevOps Engineer"

current_user=$(whoami)
current_date=$(date)
current_directory=$(pwd)

echo "Starting DevOps health check..."
echo "Hello, $name!"
echo "Target role: $role"
echo "Current user: $current_user"
echo "Current date: $current_date"
echo "Working directory: $current_directory"


