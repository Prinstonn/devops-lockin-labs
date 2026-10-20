# Linux Server Health Check

A Bash-based Linux server health monitoring tool built during my DevOps Lock-In training.

The script performs multiple infrastructure and application-level health checks and returns an overall exit status that can be consumed by other automation tools.

## Features

The script checks:

- Disk utilization
- Memory utilization
- System load
- Nginx service status
- SSH service status
- Cron service status
- External network connectivity
- Local HTTP endpoint availability

## Health Thresholds

- Disk warning threshold: 80%
- Memory warning threshold: 80%
- System load is compared against the number of available CPU cores

## Usage

Make the script executable:

```bash
chmod +x health-check.sh

Run:
./health-check.sh

Check the resulting exit status:
echo $?

Exit Codes
- 0 — All health checks passed
- 1 — One or more health checks failed
Failure Testing
The script was tested by deliberately stopping Nginx:
sudo systemctl stop nginx
./health-check.sh
echo $?

The health checker detected both:
- Nginx service failure
- HTTP endpoint failure (000)
The overall result changed to:
OVERALL STATUS: UNHEALTHY

with exit code 1.
After restoring Nginx:
sudo systemctl start nginx
./health-check.sh

the HTTP endpoint returned 200 and the overall server status returned to healthy.
Validation
Bash syntax validation:
bash -n health-check.sh

The script successfully passed Bash syntax validation.
Skills Demonstrated
- Bash scripting
- Variables and command substitution
- Positional parameters
- Conditional logic
- Functions and local variables
- Exit codes and return values
- Pipes and output redirection
- awk and text processing
- Linux resource monitoring
- systemd service monitoring
- Network troubleshooting
- HTTP health checking with curl
- Failure simulation and recovery
