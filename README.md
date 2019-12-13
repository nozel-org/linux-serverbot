# Serverbot
Remindbot is a simple and small bot that reminds you on pre-defined dates. We use it to be reminded of expiring contracts, so we can act accordingly.

It offers the following features:

| Feature | Description |
| ------- | ----------- |
| Overview | Outputs a reminders overview. |
| Reminder | Outputs only relevant reminders. |

Aside from features, there are also different methods that can be used with the features:

| Method | Description |
| ------ | ----------- |
| CLI | Feature feedback or output on the CLI. |
| Telegram | Feature feedback or output to a Telegram bot. |

# Install remindbot
Easy! But before you download software, always check its source code and/or credibility. Never trust random people on the internet ;-). If you are particularly gullible or like living on the edge, you can also skip this. To install, download [`remindbot.sh`](https://raw.githubusercontent.com/nozel-org/remindbot/stable/remindbot.sh) and place it in `/usr/bin/remindbot`. You can add the configuration file and reminders file to respectively `/etc/remindbot/remindbot.conf` and `/etc/remindbot/reminders.txt`.

Please note that you will need `wget` for automated retrieval of reminder lists.

# Use remindbot
After installing remindbot you can run `remindbot` as a normal command. For example `remindbot --overview --cli`. Parameters like automated tasks and thresholds can be configured from a central configuration file in `/etc/remindbot/remindbot.conf`.

`remind --help` provides a handy overview of arguments:
```
root@server:~# remindbot --help
Usage:
 remindbot [feature]... [method]...
 remindbot [option]...

Features:
 --overview        Show reminders overview
 --remind          Show reminders

Methods:
 --cli             Output [feature] to command line
 --telegram        Output [feature] to Telegram bot

Options:
 --cron            Effectuate cron changes from remindbot config
 --validate        Check validity of remindbot.conf
 --help            Display this help and exit
 --version         Display version information and exit
```

# Support
If you can't figure it out on your own, [create a issue](https://github.com/nozel-org/remindbot/issues/new) and we'll help you when there is time. If you find bugs: please let us know!

# Compatibility
We try to support a wide range of linux distributions. As of now, support includes most distros that support `bash`.

# Ideas
If you have any ideas to improve remindbot, let us know!
