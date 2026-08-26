# Day 1: Linux Server Administration and Nginx Troubleshooting

## Overview

This lab demonstrates foundational Linux administration and systematic service troubleshooting using an Ubuntu 22.04 LTS virtual machine.

The work followed a practical learning cycle:

**Learn → Explain → Build → Break → Troubleshoot → Document**

## Objectives

* Inspect Linux operating system, memory, disk and network information
* Navigate the Linux filesystem and manage files and directories
* Configure file permissions, ownership, users and groups
* Inspect processes, services, packages and system logs
* Deploy a basic website using Nginx
* Introduce and diagnose an Nginx configuration failure
* Restore the service and verify successful recovery

## Environment

* Ubuntu 22.04.5 LTS
* Linux kernel 5.15
* Oracle VirtualBox
* Vagrant
* Bash
* systemd
* Nginx 1.18

## Skills Demonstrated

* Linux filesystem navigation
* File permissions using `chmod`
* Ownership management using `chown`
* User and group administration
* Process inspection and termination
* Service management using `systemctl`
* Package management using APT
* Log investigation using `journalctl`
* Socket inspection using `ss`
* HTTP testing using `curl`
* Bash scripting
* Nginx installation and configuration
* Incident troubleshooting and recovery

## Project Structure

```text
day1-linux/
├── configs/
│   ├── index.html
│   └── nginx-default.conf
├── evidence/
│   ├── system-assessment.txt
│   └── team-report.txt
├── notes/
│   └── system-assessment.txt
├── scripts/
│   └── server-check.sh
├── troubleshooting/
│   └── nginx-incident.md
└── README.md
```

## Linux System Assessment

The server environment was inspected using commands including:

```bash
whoami
hostname
hostnamectl
cat /etc/os-release
ip -br address
free -h
df -h
uptime
```

The assessment collected information about:

* Current user and hostname
* Operating system and kernel
* CPU architecture
* Network interfaces and IP addresses
* Available memory
* Disk usage
* System uptime and load average

The results are stored in:

```text
notes/system-assessment.txt
```

## File Permissions and Ownership

Linux permissions were examined and modified using:

```bash
ls -l
chmod
chown
```

A practice user and DevOps group were created to test group-based access:

```bash
sudo useradd -m -s /bin/bash trainee
sudo groupadd devops
sudo usermod -aG devops trainee
```

A team report was configured with the following access:

```text
Owner: read and write
Group: read
Others: no access
```

Access was deliberately removed and restored by changing the practice user’s group membership.

## Process and Service Management

Processes were inspected using:

```bash
ps
ps aux
pgrep
jobs
```

A temporary background process was started and terminated to practise process management:

```bash
sleep 300 &
pgrep -a sleep
pkill sleep
```

Services were inspected using:

```bash
systemctl is-active
systemctl is-enabled
systemctl status
```

System logs were reviewed using:

```bash
journalctl
```

## Bash System-Check Script

A basic Bash script was created to display server information, including:

* Hostname
* Current user
* Current date and time
* System uptime

The script is located at:

```text
scripts/server-check.sh
```

It can be executed with:

```bash
./scripts/server-check.sh
```

## Nginx Deployment

Nginx was installed using:

```bash
sudo apt update
sudo apt install nginx -y
```

The service was verified using:

```bash
systemctl is-active nginx
systemctl is-enabled nginx
systemctl status nginx --no-pager
```

Nginx was configured to serve a custom webpage from:

```text
/var/www/html/index.html
```

The deployed page contained:

```html
<h1>Linux Server Administration Lab</h1>
<p>Deployed by Prinston using Nginx on Ubuntu.</p>
<p>Status: Operational</p>
```

The deployment was verified using:

```bash
sudo nginx -t
sudo ss -ltnp | grep ':80'
curl -I http://localhost
curl http://localhost
```

The server successfully returned:

```text
HTTP/1.1 200 OK
```

## Troubleshooting Exercise

A controlled configuration error was introduced by replacing the valid port number `80` with the invalid value `eighty` in the Nginx `listen` directive.

This caused:

* The Nginx configuration test to fail
* The Nginx service to enter a failed state
* Port 80 to stop listening
* HTTP connections to be refused

The incident was investigated using:

```bash
systemctl is-active nginx
systemctl status nginx --no-pager
sudo nginx -t
sudo journalctl -u nginx -n 20 --no-pager
sudo ss -ltnp | grep ':80'
curl -I --max-time 5 http://localhost
```

The configuration test identified the error in:

```text
/etc/nginx/sites-enabled/default:22
```

The known-good configuration was restored from backup:

```bash
sudo cp /etc/nginx/sites-available/default.day1-backup /etc/nginx/sites-available/default
```

The repaired configuration was tested before starting the service:

```bash
sudo nginx -t
sudo systemctl start nginx
```

Recovery was verified at the service, network and application layers:

```bash
systemctl is-active nginx
sudo ss -ltnp | grep ':80'
curl -I http://localhost
curl http://localhost
```

See the [Nginx incident report](troubleshooting/nginx-incident.md) for the complete investigation, root-cause analysis and recovery process.

## Troubleshooting Method

The incident was handled using the following sequence:

1. Observe the user-visible symptom.
2. Check the service state.
3. Test the application configuration.
4. Review the service logs.
5. Check the listening network socket.
6. Identify the root cause.
7. Restore the known-good configuration.
8. Test the repaired configuration.
9. Start the service.
10. Verify recovery at multiple layers.

## Key Outcome

I deployed an Nginx web server, diagnosed a configuration-driven outage, identified the error using configuration tests and service logs, restored a known-good configuration and verified recovery at the process, network and application layers.

## Lessons Learned

* Back up configuration files before modifying them.
* Test Nginx configuration with `nginx -t` before restarting or reloading the service.
* Use `systemctl`, `journalctl`, `ss` and `curl` together during service troubleshooting.
* A failed service can cause connection refusal when no process is listening on the expected port.
* Apply the principle of least privilege when configuring permissions.
* Verify recovery at multiple layers instead of relying on a single successful command.

