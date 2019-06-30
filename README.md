# Serverbot
Serverbot is a simple and small (<50 kilobytes/~1000 LOC) server monitoring tool that is easy to use. We found most monitoring software to be overkill for our needs and made a simplistic and lightweight alternative. It's well commented and can be easily extended or hacked to provide more features.

It offers the following features:

| Feature | Description |
| ------- | ----------- |
| Overview | Outputs a rather complete server overview. |
| Metrics | Outputs server metrics like uptime, load, ram and disk. |
| Alert | Outputs whether load, ram or disk space exceeds the configured threshold. |
| Updates | Outputs available system updates. |

Aside from features, there are also different methods that can be used with the features:

| Method | Description |
| ------ | ----------- |
| CLI | Feature feedback or output on the CLI. |
| Telegram | Feature feedback or output to a Telegram bot. |

Some examples from both Telegram and CLI:
![alt text](https://raw.githubusercontent.com/nozel-org/serverbot/master/overview.jpg "feature examples")

Using serverbot is easy, just type in 'serverbot' with both a feature and method. For example `serverbot --metrics --telegram` or the shorter notation `serverbot -m -t`. Parameters can be configured from a central configuration file in `/etc/serverbot/serverbot.conf`.

# Compatibility
We try to support a wide range of linux distributions. As of now, support includes most distro's that use apt-get, yum or dnf. This includes at least the following distributions (which are tested):

| RHEL family | Debian family | Other |
| ----------- | -------- | ------- |
| CentOS Linux 7 | Debian GNU/Linux 8 (jessie) | |
| CentOS Linux 8 | Debian GNU/Linux 9 (stretch) | |
| Fedora 27 | Debian GNU/Linux 10 (buster) | |
| Fedora 28 | Ubuntu 14.04 LTS (Trusty Tahr) | |
| Fedora 29 | Ubuntu 14.10 (Utopic Unicorn) | |
| Fedora 30 | Ubuntu 15.04 (Vivid Vervet) | |
| Fedora 31 | Ubuntu 15.10 (Wily Werewolf) | |
| | Ubuntu 16.04 LTS (Xenial Xerus) | | | | | |
| | Ubuntu 16.10 (Yakkety Yak) | |
| | Ubuntu 17.04 (Zesty Zapus) | |
| | Ubuntu 17.10 (Artful Aardvark) | |
| | Ubuntu 18.04 LTS (Bionic Beaver) | |
| | Ubuntu 18.10 (Cosmic Cuttlefish) | |
| | Ubuntu 19.04 (Disco Dingo) | |
| | Ubuntu 19.10 LTS (Eoan Ermine) | |

# Future plans
Ideas and plans for future features are:

* Extend feature alert with SSD life expectancy.
* Extend feature alert or add feature login with realtime logins and currently logged in users.
* Extend feature alert with filesystem monitoring.
* Extend feature alert with CPU / HDD temperature monitoring.
* Extend feature alert with USB device monitoring.
* Add method email.
* Add feature outage which monitors the availability of other remote systems and reports the status.
* Add support for Alpine Linux.
* Add support for NixOS.

New ideas are welcome!
