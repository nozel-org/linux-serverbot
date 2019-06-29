# serverbot
Serverbot is a simple (<100 kilobytes) and easy to use server monitoring tool that is in development for usage in our own infrastructure. When version 1.0 ready, it will have the following features:

| Feature | Description |
| ------- | ----------- |
| Overview | Outputs a rather complete server overview. |
| Metrics | Outputs server metrics like uptime, load, ram and disk. |
| Alert | Outputs whether load, ram or disk space exceeds the configured threshold. |
| Updates | Outputs available system updates. |

Aside from features, there are also different methods that can be used with the featurs. In 1.0, the following methods will be available:

| Method | Description |
| ------ | ----------- |
| CLI | Feature feedback or output on the CLI. |
| Telegram | Feature feedback or output to a Telegram bot. |

Using serverbot is easy, just type in 'serverbot' with both a feature and method. For example `serverbot --metrics --telegram` or the shorter notation `serverbot -m -t`. Parameters can be configured from a central configuration file in `/etc/serverbot/serverbot.conf`.

# compatibility and progress
Some of the features use linux distribution specific dependencies or components, which unfortunately means that not all features are universally usable on all linux distributions. The table below shows the current support of features for linux distro's we are currently focussing on.

| Distribution | Overview | Metrics | Alert | Updates | CLI | Telegram |
| ------------ | -------- | ------- | ----- | ------- | --- | -------- |
| CentOS Linux 7 | | | | | | |
| CentOS Linux 8 | N/A | N/A | N/A | N/A | N/A | N/A |
| Fedora 27 | | | | | | |
| Fedora 28 | | | | | | |
| Fedora 29 | | | | | | |
| Fedora 30 | | | | | | |
| Fedora 31 | N/A | N/A | N/A | N/A | N/A | N/A |
| Debian GNU/Linux 8 (Jessie) | OK | OK | OK | OK | OK | OK |
| Debian GNU/Linux 9 (Stretch) | OK | OK | OK | OK | OK | OK |
| Debian GNU/Linux 10 (Buster) | | | | | | |
| Debian GNU/Linux 11 (Bullseye) | N/A | N/A | N/A | N/A | N/A | N/A |
| Ubuntu 14.04 LTS (Trusty Tahr) | OK | OK | OK | OK | OK | OK |
| Ubuntu 14.10 (Utopic Unicorn) | OK | OK | OK | OK | OK | OK |
| Ubuntu 15.04 (Vivid Vervet) | OK | OK | OK | OK | OK | OK |
| Ubuntu 15.10 (Wily Werewolf) | OK | OK | OK | OK | OK | OK |
| Ubuntu 16.04 LTS (Xenial Xerus) | | | | | | |
| Ubuntu 16.10 (Yakkety Yak) | | | | | | |
| Ubuntu 17.04 (Zesty Zapus) | | | | | | |
| Ubuntu 17.10 (Artful Aardvark) | | | | | | |
| Ubuntu 18.04 LTS (Bionic Beaver) | | | | | | |
| Ubuntu 18.10 (Cosmic Cuttlefish) | | | | | | |
| Ubuntu 19.04 (Disco Dingo) | | | | | | |
| Ubuntu 19.10 LTS (Eoan Ermine) | N/A | N/A | N/A | N/A | N/A | N/A |

# examples
```
root@server:~# serverbot --overview --cli

# SYSTEM #
HOST:         server
OS:           GNU/Linux
DISTRO:       Debian GNU/Linux 9
KERNEL:       Linux 4.9.0-9-amd64
ARCHITECTURE: x86_64
UPTIME:       up 5 days, 1 hour, 33 minutes

# INTERNAL IP:
121.100.21.39
1000:500:0:f816:3eff:feff:fe63:2239

# EXTERNAL IP:
121.100.21.39

# HEALTH INFORMATION #
LOAD:         0.00 0.00 0.00
MEMORY:       51M / 3955M (1%)
DISK:         1.2G / 40G (4%)
```
```
root@server:~# serverbot --metrics --cli

HOST:     server
UPTIME:   up 5 days, 1 hour, 31 minutes
LOAD:     0.00 0.00 0.00
MEMORY:   51M / 3955M (1%)
DISK:     1.2G / 40G (4%)
```
```
root@server:~# serverbot --alert --cli

[i] SERVER LOAD:        A current server load of 0% does not exceed the threshold of 1%.
[!] SERVER MEMORY:      A current memory usage of 1% exceeds the threshold of 1%.
[!] DISK USAGE:         A current disk usage of 4% exceeds the threshold of 1%.
```

# future
Ideas and plans for future features are:

* Extend feature backup with LXD containers.
* Extend feature backup with checksums.
* Extend feature alert with SSD life expectancy.
* Extend feature alert or add feature login with realtime logins and currently logged in users.
* Extend feature alert with filesystem monitoring.
* Extend feature alert with CPU / HDD temperature monitoring.
* Extend feature alert with USB device monitoring.
* Add a argument valididy check.
* Add method email.
* Add feature outage which monitors the availability of other remote systems and reports the status.
* Add support for Alpine Linux.
* Add support for Fedora 31.
* Add support for NixOS.
* Add feature backup which backups files, containers and other stuff automatically.

New ideas are welcome!
