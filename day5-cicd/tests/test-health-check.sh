
#!/bin/bash

set -e

echo "Running automated health-check tests..."

output=$(bash day5-cicd/health-check.sh)

check_output() {
    local expected="$1"
    local description="$2"

    if grep -Fq "$expected" <<< "$output"; then
        echo "PASS: $description"
    else
        echo "FAIL: $description"
        echo "Expected output: $expected"
        exit 1
    fi
}

check_output "DEVOPS SYSTEM HEALTH CHECK" "Correct heading"
check_output "Hostname:" "Hostname section"
check_output "Memory usage:" "Memory section"
check_output "Health check completed successfully!" "Completion message"

echo "All automated tests passed!"
