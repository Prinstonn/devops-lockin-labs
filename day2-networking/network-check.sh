#!/bin/bash

echo "=== NETWORK DIAGNOSTIC REPORT ==="
echo


echo "[1] Network interfaces and IP addresses"
ip -br address
echo


echo "[2] Routing Table and default Gateway"
ip route
echo

echo "[3] Gateway connectivity"
GATEWAY=$(ip route | awk '/default/ {print $3; exit}')

if ping -c 2 -W 2 "$GATEWAY" >/dev/null 2>&1; then
    echo "PASS: Gateway $GATEWAY is reachable"
else
    echo "FAIL: Gateway $GATEWAY is unreachable"
fi
echo

echo "[4] Internet connectivity"
if ping -c 2 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "PASS: Internet IP 8.8.8.8 is reachable"
else
    echo "FAIL: Internet IP 8.8.8.8 is unreachable"
fi
echo


echo "[5] DNS resolution"
if getent hosts google.com >/dev/null 2>&1; then
    echo "PASS: google.com resolves successfully"
else
    echo "FAIL: google.com could not be resolved"
fi
echo

echo "[6] Remote TCP port"
if nc -z -w 5 google.com 443 >/dev/null 2>&1; then
    echo "PASS: google.com TCP port 443 is reachable"
else
    echo "FAIL: google.com TCP port 443 is unreachable"
fi
echo

echo "[7] Local Nginx HTTP service"
if curl -fsSI --max-time 5 http://127.0.0.1 >/dev/null 2>&1; then
    echo "PASS: Nginx returned a successful HTTP response"
else
    echo "FAIL: Nginx did not return a successful HTTP response"
fi
echo

echo "[8] Listening TCP sockets"
sudo ss -ltnp
