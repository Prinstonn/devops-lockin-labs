# Day 2 — Linux Networking and Connectivity Troubleshooting

## Overview

This lab focused on Linux networking fundamentals, subnetting, DNS, TCP/UDP, ports, sockets, HTTP request flow, and systematic connectivity troubleshooting.

A controlled Nginx incident was created by restricting the service to loopback interfaces. The failure was diagnosed using service, socket, and HTTP tests, then corrected and verified.

## Environment

- Ubuntu 22.04 Linux VM
- Vagrant and VirtualBox
- Network interface: `enp0s3`
- VM IPv4 address: `10.0.2.15/24`
- Default gateway: `10.0.2.2`
- Web server: Nginx 1.18
- HTTP port: TCP `80`
- SSH port: TCP `22`

## Topics Practised

- IPv4 addresses and subnet masks
- Network and host portions
- `/16`, `/24`, `/25`, `/26`, and `/27` prefixes
- Network, usable-host, and broadcast addresses
- Block-size subnetting
- Default gateways and routing
- DNS resolution and local stub resolvers
- TCP versus UDP
- TCP three-way handshake
- Ports, listening services, and sockets
- Loopback versus network-interface binding
- HTTP and HTTPS request flow
- Layered network troubleshooting

## Troubleshooting Method

The lab used the following troubleshooting order:

```text
Interface → IP address → Gateway → Internet → DNS → Port → Service
```

## Commands Used

```bash
ip -br address
ip route
ping -c 4 10.0.2.2
ping -c 4 8.8.8.8
ping -c 4 google.com
resolvectl query google.com
resolvectl status
nc -vz google.com 443
curl -I https://google.com
curl -vI https://google.com
sudo ss -ltnp
sudo nginx -t
systemctl is-active nginx
```

## HTTPS Request Flow

When a client accesses an HTTPS URL, the request generally follows this sequence:

```text
DNS resolution
→ Routing
→ TCP three-way handshake
→ TLS handshake
→ HTTP request
→ HTTP response
```

The verbose `curl` test confirmed:

- DNS resolution of `google.com`
- TCP connection to port `443`
- TLS 1.3 negotiation
- Successful certificate verification
- HTTP `HEAD` request
- HTTP `301` redirect response

## Controlled Incident

### Scenario

Nginx was running, but the website could not be accessed through the VM's network address:

```text
http://10.0.2.15
```

However, the service remained accessible locally through:

```text
http://127.0.0.1
```

### Fault Introduced

The Nginx listening configuration was changed from all interfaces:

```nginx
listen 80 default_server;
listen [::]:80 default_server;
```

to loopback interfaces only:

```nginx
listen 127.0.0.1:80 default_server;
listen [::1]:80 default_server;
```

### Symptoms

The loopback request succeeded:

```text
curl -I http://127.0.0.1
HTTP/1.1 200 OK
```

The VM-interface request failed:

```text
curl -I http://10.0.2.15
Connection refused
```

### Diagnosis

Nginx was active and capable of serving HTTP, but it was listening only on loopback sockets. It could not accept connections directed to the VM's `10.0.2.15` network interface.

The socket inspection command exposed the incorrect binding:

```bash
sudo ss -ltnp | grep ':80'
```

### Resolution

The original Nginx configuration was restored, validated, and restarted:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

Post-fix socket inspection showed:

```text
0.0.0.0:80
[::]:80
```

Both HTTP tests then returned `200 OK`:

```bash
curl -I http://127.0.0.1
curl -I http://10.0.2.15
```

## Network Diagnostic Script

The `network-check.sh` script automates checks for:

1. Network interfaces and IP addresses
2. Routing table and default gateway
3. Gateway reachability
4. Internet connectivity
5. DNS resolution
6. Remote TCP port connectivity
7. Local Nginx HTTP response
8. Listening TCP sockets

### Usage

```bash
chmod +x network-check.sh
./network-check.sh
```

### Syntax Validation

```bash
bash -n network-check.sh
echo $?
```

An exit status of `0` confirms that Bash found no syntax errors.

## Key Lessons

- A running service is not necessarily accessible through the network.
- `127.0.0.1` refers to the local machine only.
- `0.0.0.0` means a service is listening across all IPv4 interfaces.
- `Connection refused` does not necessarily mean the host is unreachable.
- DNS, routing, ports, firewalls, socket bindings, and service health must be tested separately.
- Configuration syntax should be validated before restarting or reloading a service.
- Backups of Nginx site files should not be placed in `sites-enabled`, because Nginx loads every file in that directory.
- Troubleshooting should be based on observed evidence rather than assumptions.

## Interview Explanation

I diagnosed an Nginx connectivity incident where the service was active and responded through localhost but refused connections through the VM's network IP. I compared HTTP results for `127.0.0.1` and `10.0.2.15`, inspected listening sockets with `ss`, and found that Nginx was bound only to loopback interfaces. I restored the wildcard bindings, validated the configuration with `nginx -t`, restarted the service, and verified successful HTTP responses through both addresses.
