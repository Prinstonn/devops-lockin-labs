# Nginx Configuration Failure and Recovery

## Incident Summary

Nginx failed to start after an invalid value was introduced into the `listen` directive. As a result, no process was listening on TCP port 80, and HTTP requests to the server were refused.

## Healthy Baseline

Before the incident:

* The Nginx service was active and enabled.
* Nginx was listening on TCP port 80.
* `curl` returned HTTP status `200 OK`.
* `nginx -t` reported that the configuration was valid.

## Symptom

An HTTP request to the local server failed with:

```text
curl: (7) Failed to connect to localhost port 80: Connection refused
```

## Investigation

The service state was checked using:

```bash
systemctl status nginx --no-pager
```

Systemd reported that the Nginx service had failed.

The configuration was then tested using:

```bash
sudo nginx -t
```

Nginx reported:

```text
host not found in "eighty" of the "listen" directive
```

The error was located in:

```text
/etc/nginx/sites-enabled/default:22
```

Service logs were reviewed using:

```bash
sudo journalctl -u nginx -n 20 --no-pager
```

A socket check confirmed that no process was listening on TCP port 80:

```bash
sudo ss -ltnp | grep ':80'
```

The server was also tested using:

```bash
curl -I --max-time 5 http://localhost
```

The connection was refused because Nginx was not running and no process was accepting connections on port 80.

## Root Cause

The valid numeric port `80` had been replaced with the invalid value `eighty` in the Nginx `listen` directive.

Nginx interpreted `eighty` as a hostname rather than a valid port number. Because Nginx could not load the invalid configuration, the service failed to start.

The configuration error appeared under `/etc/nginx/sites-enabled/default` because this file is a symbolic link to the active configuration stored at `/etc/nginx/sites-available/default`.

## Resolution

The known-good configuration was restored from backup:

```bash
sudo cp /etc/nginx/sites-available/default.day1-backup /etc/nginx/sites-available/default
```

The configuration was tested before starting the service:

```bash
sudo nginx -t
```

The test returned:

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

After the configuration test succeeded, Nginx was started:

```bash
sudo systemctl start nginx
```

## Verification

The service state was verified using:

```bash
systemctl is-active nginx
systemctl status nginx --no-pager
```

The result showed that Nginx was active and running.

The listening socket was verified using:

```bash
sudo ss -ltnp | grep ':80'
```

The HTTP response headers were tested using:

```bash
curl -I http://localhost
```

The server returned:

```text
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
```

The webpage content was verified using:

```bash
curl http://localhost
```

Nginx returned the custom webpage:

```html
<h1>Linux Server Administration Lab</h1>
<p>Deployed by Prinston using Nginx on Ubuntu.</p>
<p>Status: Operational</p>
```

Finally, the service logs were reviewed again:

```bash
sudo journalctl -u nginx -n 15 --no-pager
```

The logs confirmed that Nginx started successfully after the valid configuration was restored.

## Troubleshooting Method

The incident was resolved using the following sequence:

1. Reproduce and observe the connection failure.
2. Check the Nginx service state with `systemctl`.
3. Test the configuration with `nginx -t`.
4. Review the service logs with `journalctl`.
5. Confirm that no process is listening on port 80 with `ss`.
6. Identify the invalid `listen` directive.
7. Restore the known-good configuration.
8. Test the configuration before starting Nginx.
9. Start the service and verify it at the service, network and HTTP layers.

## Lessons Learned

* Back up configuration files before modifying them.
* Run `nginx -t` before restarting or reloading Nginx.
* Use service status, configuration tests, logs, socket checks and HTTP requests together.
* A failed service can cause connection refusal when no process is listening on the expected port.
* The `sites-enabled` configuration can be a symbolic link to a file stored in `sites-available`.
* Restore known-good files with `cp` when the backup should be preserved.
* Verify recovery at multiple layers instead of assuming that a successful command means the application is healthy.

