
#!/bin/bash

set -e

echo "Running automated health-check tests..."

# Execute the original script and capture its output
output=$(bash day5-cicd/health-check.sh)

# Test 1: Verify the heading exists
echo "$output" | grep -q "DEVOPS SYSTEM HEALTH CHECK"
echo "PASS: Correct heading found"

# Test 2: Verify hostname section exists
echo "$output" | grep -q "Hostname:"
echo "PASS: Hostname section found"

# Test 3: Verify memory section exists
echo "$output" | grep -q "Memory usage:"
echo "PASS: Memory section found"

# Test 4: Verify completion message exists
echo "$output" | grep -q "Health check completed successfully!"
echo "PASS: Completion message found"

echo "All automated tests passed!"
