
#!/bin/bash

set -e

echo "================================="
echo "  DEVOPS SYSTEM HEALTH CHECK"
echo "================================="

echo "Hostname:"
hostname

echo "Current user:"
whoami

echo "Kernel version:"
uname -r

echo "Disk usage:"
df -h /

echo "Memory usage:"
free -h

echo "Health check completed successfully!"
