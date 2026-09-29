#!/bin/bash

URL="${1:-http://localhost}"

echo "=== Deployment Validation ==="
echo "Checking: $URL"

HTTP_STATUS=$(curl -s --max-time 10 -o /dev/null -w "%{http_code}" "$URL")
CURL_EXIT=$?

if [ "$CURL_EXIT" -ne 0 ]; then
    echo "FAIL: Unable to connect to $URL"
    exit 1
elif [ "$HTTP_STATUS" -eq 200 ]; then
    echo "PASS: Deployment is healthy (HTTP $HTTP_STATUS)"
    exit 0
else
    echo "FAIL: Deployment returned HTTP $HTTP_STATUS"
    exit 1
fi
