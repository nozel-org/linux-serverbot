# Serverbot
Serverbot is a simple and small (<50 kilobytes/<1500 LOC) server monitoring tool that is both easy to use and easy to extend. We found most monitoring software to be overkill for our needs and made a simplistic and lightweight alternative. It's well commented and can be easily extended or hacked to provide more features.

It offers the following features:

| Feature | Description |
| ------- | ----------- |
| Overview | Outputs a rather complete server overview. |
| Metrics | Outputs server metrics like uptime, load, ram and disk. |
| Alert | Outputs whether load, ram or disk space exceeds the configured threshold. |
| Updates | Outputs available system updates. |
| EOL | Outputs whether the operating system is end-of-life. |

Aside from features, there are also different methods that can be used with the features:

| Method | Description |
| ------ | ----------- |
| CLI | Feature feedback or output on the CLI. |
| Telegram | Feature feedback or output to a Telegram bot. |

Some examples from both Telegram and CLI:
![alt text](https://raw.githubusercontent.com/nozel-org/serverbot/stable/resources/overview.jpg "feature examples")

# Install serverbot
Easy! But before you download software, always check its source code and/or credibility. Never trust random people on the internet ;-). If you are particularly gullible or like living on the edge, you can also skip this. To install, download [`serverbot.sh`](https://raw.githubusercontent.com/nozel-org/serverbot/stable/serverbot.sh) to your device and run `bash serverbot.sh --install` to install.

Some common methods of downloading the file would be:
```
wget https://raw.githubusercontent.com/nozel-org/serverbot/master/serverbot.sh
curl -O https://raw.githubusercontent.com/nozel-org/serverbot/master/serverbot.sh
```

# Use serverbot
After installing serverbot you can run `serverbot` as a normal command. For example `serverbot --metrics --cli` or the shorter notation `serverbot -m -c`. Parameters like automated tasks and thresholds can be configured from a central configuration file in `/etc/serverbot/serverbot.conf`.

`serverbot --help` provides a handy overview of arguments:
```
root@server:~# serverbot --help
Usage:
 serverbot [feature]... [method]...
 serverbot [option]...

Features:
 --overview        Show server overview
 --metrics         Show server metrics
 --alert           Show server alert status
 --updates         Show available server updates
 --eol             Show end-of-life status of operating system

Methods:
 --cli             Output [feature] to command line
 --telegram        Output [feature] to Telegram bot

Options:
 --cron            Effectuate cron changes from serverbot config
 --validate        Check validity of serverbot.conf
 --install         Installs serverbot on the system and unlocks all features
 --upgrade         Upgrade serverbot to the latest stable version
 --uninstall       Uninstalls serverbot from the system
 --help            Display this help and exit
 --version         Display version information and exit
```

For information on how to aquire a Telegram bot, look at [Telegram's documentation](https://core.telegram.org/bots).

# Support
If you can't figure something out, take a look at the [documentation](https://github.com/nozel-org/serverbot/tree/stable/docs). If you can't figure it out on your own, [create a issue](https://github.com/nozel-org/serverbot/issues/new) and we'll help you when there is time. If you find bugs: please let us know!

# Compatibility
We try to support a wide range of linux distributions. As of now, support includes most distros set to English that use `dpkg` (`apt-get`, `apt`), `rpm` (`yum`, `dnf`), `systemd` and `bash`. This should include at least the following distributions (which have been tested during developement):

| Distro name | Compatible releases |
| ----------- | ------------------- |
| Debian GNU/Linux | 8, 9, 10 |
| Ubuntu | 14.04 LTS, 14.10, 15.04, 15.10, 16.04 LTS, 16.10, 17.04, 17.10, 18.04 LTS, 18.10, 19.04, 19.10 LTS |
| RHEL | 7, 8 |
| CentOS | 7, 8 |
| Fedora | 27, 28, 29, 30, 31 |

Note that `feature eol` specifically will only work on pre-defined distributions. Let us know what distro you use, and we will add full support for it as long as it meets the basic requirements of `serverbot`.

# Roadmap
The below ideas are planned for future releases of `serverbot`.
- [X] Add feature end-of-life that notifies when the OS is nearing EOL status (Q3 2019).
- [ ] Add feature outage that monitors the availability of remote systems and reports the status (Q1 2020).
- [ ] Add method email (Q1 2020).
- [ ] Add feature audit that audits (web)servers (TLS, security headers, firewalls, DNS records etc.) (Q2 2020)

# Ideas
The below ideas are unplanned for future releases of `serverbot`.

- [ ] Extend feature alert with SSD life expectancy.
- [ ] Extend feature alert or add feature login with realtime logins and currently logged in users.
- [ ] Extend feature alert with filesystem monitoring.
- [ ] Extend feature alert with CPU / HDD temperature monitoring.
- [ ] Extend feature alert with USB device monitoring.
- [ ] Extend feature alert with notice on shutdown and boot.
- [ ] Extend feature overview with total network traffic amount.
- [ ] Extend feature overview with logged in users.
- [ ] Add support for Alpine Linux.
- [ ] Add support for NixOS.
- [ ] Add support for FreeBSD.
- [ ] Add support for OpenBSD.

More ideas are welcome!
