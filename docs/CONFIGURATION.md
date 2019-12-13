
*VERSION 1.0.0 (18-09-2019)*
___

This doc file should help you on your way with configuring `serverbot` to your own taste. `serverbot`'s parameters are primarily controlled via a central configuration file located in `/etc/serverbot/serverbot.conf`. The installer (`serverbot --install`) makes sure this file is installed, but you could also add it manually to `/etc/serverbot/`. 

You need to run `serverbot --cron` to effectuate any changes made to `serverbot.conf` to the operating system (mostly because of cronjobs). Using `serverbot --cron` will also do some basic syntax validation for most of these variables, so making mistakes is harder. Correct syntax is important since `serverbot.conf` gets sourced by `serverbot` upon usage, and a small typo can lead to unexpected or unwanted behavior.

`/etc/serverbot/serverbot.conf` doesn't get automatically updated when updating `serverbot`. When you upgrade to a newer version of `serverbot` that adds more features, simply add the variables that were introduced with the new version to `/etc/serverbot/serverbot.conf` and you are good to go.


# 1 VALID CONFIGURATION
## 1.1 VERSION AND BRANCH CONTROL
| Variable | Valid | Introduced | Default | Description |
| -------- | ----- | ---------- | ------- | ----------- |
| `MAJOR_VERSION` | `1` | `1.0.0` | `1` | Lets you upgrade `serverbot` to new major versions (e.g. from `1.x.x` to `2.x.x`). This is in preparation for a new major release. |
| `SERVERBOT_BRANCH` | `stable`, `unstable` | `1.1.0` | `stable` | Lets you select the branch for `serverbot`. Only using the `stable` branch is adviced. The `unstable` branch contains all latest features, but these are accompanied by an army of bugs. |

## 1.2 AUTOMATED TASKS
### 1.2.1 AUTOMATIC UPDATES
| Variable | Valid | Introduced | Default | Description |
| -------- | ----- | ---------- | ------- | ----------- |
| `SERVERBOT_UPGRADE` | `yes`, `no` | `1.0.0` | `no` | Whether new versions of `serverbot` are automatically found and installed or not. The frequency is based on `SERVERBOT_UPGRADE_CRON`. |
| `SERVERBOT_UPGRADE_CRON` | cron format | `1.0.0` | `0 1 * * *` | Schedules `SERVERBOT_UPGRADE`. Does nothing if `SERVERBOT_UPGRADE` is set to `no`. |
| `SERVERBOT_UPGRADE_TELEGRAM` | `yes`, `no` | `1.1.0` | `no` | Whether `serverbot` sents a notification via `method telegram` on update. Does nothing if `SERVERBOT_UPGRADE` is set to `no` or if `method telegram` is not configured. |

### 1.2.2 FEATURES
| Variable | Valid | Introduced | Default | Description |
| -------- | ----- | ---------- | ------- | ----------- |
| `OVERVIEW_TELEGRAM` | `yes`, `no` | `1.0.0` | `no` | Whether `feature overview` with `method telegram` is automatically run or not. The frequency is based on `OVERVIEW_CRON`. |
| `OVERVIEW_CRON` | cron format | `1.0.0` | `0 8 * * 1` | Schedules `OVERVIEW_TELEGRAM`. Does nothing if `OVERVIEW_TELEGRAM` is set to `no` of if `method telegram` is not configured. |
| `METRICS_TELEGRAM` | `yes`, `no` | `1.0.0` | `no` | Whether `feature metrics` with `method telegram` is automatically run or not. The frequency is based on `METRICS_CRON`. |
| `METRICS_CRON` | cron format | `1.0.0` | `0 8 * * 1` | Schedules `METRICS_TELEGRAM`. Does nothing if `METRICS_TELEGRAM` is set to `no` of if `method telegram` is not configured. |
| `ALERT_TELEGRAM` | `yes`, `no` | `1.0.0` | `no` | Whether `feature alert` with `method telegram` is automatically run or not. The frequency is based on `ALERT_CRON`. |
| `ALERT_CRON` | cron format | `1.0.0` | `0 * * * *` | Schedules `ALERT_TELEGRAM`. Does nothing if `ALERT_TELEGRAM` is set to `no` of if `method telegram` is not configured. |
| `UPDATES_TELEGRAM` | `yes`, `no` | `1.0.0` | `no` | Whether `feature updates` with `method telegram` is automatically run or not. The frequency is based on `UPDATES_CRON`. |
| `UPDATES_CRON` | cron format | `1.0.0` | `0 12 * * *` | Schedules `UPDATES_TELEGRAM`. Does nothing if `UPDATES_TELEGRAM` is set to `no` of if `method telegram` is not configured. |
| `EOL_TELEGRAM` | `yes`, `no` | `1.1.0` | `no` | Whether `feature eol` with `method telegram` is automatically run or not. The frequency is based on `EOL_CRON`. |
| `EOL_CRON` | cron format | `1.1.0` | `0 6 * * 3` | Schedules `EOL_TELEGRAM`. Does nothing if `EOL_TELEGRAM` is set to `no` of if `method telegram` is not configured. |

## 1.3 FEATURES
### 1.3.1 FEATURE ALERT
| Variable | Valid | Introduced | Default | Description |
| -------- | ----- | ---------- | ------- | ----------- |
| `THRESHOLD_LOAD` | Rounded number between `0` - `100` and must end with '`%`'. | `1.0.0` | `90%` | Alert threshold for load. |
| `THRESHOLD_MEMORY` | Rounded number between `0` - `100` and must end with '`%`'. | `1.0.0` | `80%` | Alert threshold for memory. |
| `THRESHOLD_DISK` | Rounded number between `0` - `100` and must end with '`%`'. | `1.0.0` | `80%` | Alert threshold for disk. |

## 1.4 METHODS
### 1.4.1 METHOD TELEGRAM
| Variable | Valid | Introduced | Default | Description |
| -------- | ----- | ---------- | ------- | ----------- |
| `TELEGRAM_TOKEN` | valid token | `1.0.0` | `telegram_token_here` | [Telegram bot documentation](https://core.telegram.org/bots) |
| `TELEGRAM_CHAT` | valid token | `1.0.0` | `telegram_id_here` | [Telegram bot documentation](https://core.telegram.org/bots) |
| `TELEGRAM_URL` | valid url | `1.0.0` | `https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage` | Leave default when using official Telegram API.
