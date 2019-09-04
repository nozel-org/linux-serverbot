# Serverbot
Serverbot is a simple and small (<50 kilobytes/~1000 LOC) server monitoring tool that is both easy to use and easy to extend. We found most monitoring software to be overkill for our needs and made a simplistic and lightweight alternative. It's well commented and can be easily extended or hacked to provide more features.

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

# How to use serverbot
Easy! Download [`serverbot.sh`](https://raw.githubusercontent.com/nozel-org/serverbot/master/serverbot.sh) to your device and run it (`bash serverbot.sh --install`) to install. After installing serverbot you can just run `serverbot` as a normal command. For example `serverbot --metrics --cli` or the shorter notation `serverbot -m -c`. Parameters like automated tasks and thresholds can be configured from a central configuration file in `/etc/serverbot/serverbot.conf`.

`serverbot --help` provides an easy overview of arguments:
```
root@server:~# serverbot --help
Usage:
 serverbot [feature]... [method]...
 serverbot [option]...

Features:
 -o, --overview        Show server overview
 -m, --metrics         Show server metrics
 -a, --alert           Show server alert status
 -u, --updates         Show available server updates

Methods:
 -c, --cli             Output [feature] to command line
 -t, --telegram        Output [feature] to Telegram bot

Options:
 --cron               Effectuate cron changes from serverbot config
 --install            Installs serverbot on the system and unlocks all features
 --upgrade            Upgrade serverbot to the latest stable version
 --uninstall          Uninstalls serverbot from the system
 --help               Display this help and exit
 --version            Display version information and exit
```

For information on how to aquire a Telegram bot, look at [Telegram's documentation](https://core.telegram.org/bots).

# Compatibility
We try to support a wide range of linux distributions. As of now, support includes most distro's that use apt-get, yum or dnf and systemd. This includes at least the following distributions (which are tested):

| Distro name | Compatible releases |
| ----------- | ------------------- |
| Debian GNU/Linux | 8 (jessie), 9 (stretch), 10 (buster) |
| Ubuntu | 14.04 LTS (Trusty Tahr), 14.10 (Utopic Unicorn), 15.04 (Vivid Vervet), 15.10 (Wily Werewolf), 16.04 LTS (Xenial Xerus), 16.10 (Yakkety Yak), 17.04 (Zesty Zapus), 17.10 (Artful Aardvark), 18.04 LTS (Bionic Beaver), 18.10 (Cosmic Cuttlefish), 19.04 (Disco Dingo), 19.10 LTS (Eoan Ermine) |
| RHEL | 7, 8 |
| CentOS | 7, 8 |
| Fedora | 27, 28, 29, 30, 31 |

# Future plans
Ideas and plans for future features are:

* Extend feature alert with SSD life expectancy.
* Extend feature alert or add feature login with realtime logins and currently logged in users.
* Extend feature alert with filesystem monitoring.
* Extend feature alert with CPU / HDD temperature monitoring.
* Extend feature alert with USB device monitoring.
* Extend feature overview with logged in users.
* Add method email.
* Add feature EOL which notifies the user whenever the OS is nearing EOL status.
* Add feature outage which monitors the availability of other remote systems and reports the status.
* Add support for Alpine Linux.
* Add support for NixOS.

New ideas are welcome!
