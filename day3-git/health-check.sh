#!/bin/bash

echo "=== Git Lab Health Check ==="
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Current branch: $(git branch --show-current)"
echo "Latest commit: $(git log -1 --oneline)"
