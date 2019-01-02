#!/bin/bash

#############################################################################
# Version 0.4.1-ALPHA (02-01-2019)
#############################################################################

#############################################################################
# Copyright 2016-2019 Nozel/Sebas Veeke. Licenced under a Creative Commons 
# Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# See https://creativecommons.org/licenses/by-nc-sa/4.0/
#
# Contact:
# > e-mail      mail@nozel.org
# > GitHub      onnozel
#############################################################################

# THIS SCRIPT HAS THE FOLLOWING LAY-OUT
# - VARIABLES
# - GENERAL FUNCTIONS
# - MANAGEMENT FUNCTIONS
# - REQUIREMENT FUNCTIONS
# - GATHER FUNCTIONS
# - FEATURE FUNCTIONS
# - METHOD FUNCTIONS
# - MAIN FUNCTION

#############################################################################
# VARIABLES
#############################################################################

# serverbot version
VERSION='0.4.1'

# check whether serverbot.conf is available and source it
if [ -f /etc/serverbot/serverbot.conf ]; then
    source /etc/serverbot/serverbot.conf
else
    # otherwise use these default values
    #FEATURE_METRICS='enabled'
    #FEATURE_ALERT='enabled'
    #FEATURE_UPDATES='enabled'
    #FEATURE_LOGIN='disabled' # work in progress
    #FEATURE_OUTAGE='disabled' # work in progress
    #FEATURE_BACKUP='enabled'
    #FEATURE_FILES='enabled'
    #FEATURE_SQL='enabled'
    METHOD_CLI='enabled'
    METHOD_TELEGRAM='disabled' # won't work without serverbot.conf
    METHOD_EMAIL='disabled' # won't work without serverbot.conf
    FEATURE_CRON='disabled' # won't work without serverbot.conf
    FEATURE_CONFIG='enabled'
    FEATURE_UPGRADE='disabled' # won't work without serverbot.conf ### maybe use --upgrade for both install and upgrade with --install linking to --upgrade

    # alert threshold
    THRESHOLD_LOAD='90%'
    THRESHOLD_MEMORY='80%'
    THRESHOLD_DISK='80%'

    # backup retention in number of days.
    #RETENTION_DAILY='14'
    #RETENTION_WEEKLY='180'
    #RETENTION_MONTHLY='180'
    #RETENTION_YEARLY='0'
fi

#############################################################################
# PASS ARGUMENTS TO VARIABLES
#############################################################################

# enable help, version and a cli option
while test -n "$1"; do
    case "$1" in
        # options
        --version)
            echo
            echo "ServerBot ${VERSION}"
            echo "Copyright (C) 2018 Nozel."
            echo
            echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
            echo
            echo "Written by Sebas Veeke"
            echo
            shift
            ;;

        --help|-help|help|--h|-h)
            echo
            echo "Usage:"
            echo " serverbot [feature/option]... [method]..."
            echo
            echo "Features:"
            echo " -m, --metrics         Show server metrics"
            echo " -a, --alert           Show server alert status"
            echo " -u, --updates         Show available server updates"
            echo " -o, --outage          Check list for outage"
            echo " -b, --backup          Backup sql and files"
            echo " -f, --files           Backup only files"
            echo " -s, --sql             Backup only sql"
            echo
            echo "Methods:"
            echo " -c, --cli             Output [feature] to command line"
            echo " -t, --telegram        Output [feature] to Telegram bot"
            echo " -e, --email           Output [feature] to e-mail"
            echo
            echo "Options:"
            echo " --cron               Effectuate cron changes from serverbot config"
            echo " --config             Generates serverbot.conf to unlock all features"
            echo " --upgrade            Upgrade serverbot to the latest stable version"
            echo " --help               Display this help and exit"
            echo " --version            Display version information and exit"
            echo
            shift
            ;;

        # features
        --metrics|-metrics|metrics|-m)
            ARGUMENT_METRICS='1'
            shift
            ;;

        --alert|-alert|alert|-a)
            ARGUMENT_ALERT='1'
            shift
            ;;

        --updates|-updates|updates|-u)
            ARGUMENT_UPDATES='1'
            shift
            ;;

        --outage|-outage|outage|-o)
            ARGUMENT_OUTAGE='1'
            shift
            ;;

        --backup|-backup|backup|-b)
            ARGUMENT_BACKUP='1'
            shift
            ;;

        --files|-files|files|-f)
            ARGUMENT_BACKUP='1'
            shift
            ;;

        --sql|-sql|sql|-s)
            ARGUMENT_BACKUP='1'
            shift
            ;;

        # methods
        --cli|-cli|cli|-c)
            ARGUMENT_CLI='1'
            shift
            ;;

        --telegram|-telegram|telegram|-t)
            ARGUMENT_TELEGRAM='1'
            shift
            ;;

        --email|-email|email|-e)
            ARGUMENT_EMAIL='1'
            shift
            ;;

        # options
        --cron)
            ARGUMENT_CRON='1'
            shift
            ;;

        --config)
            ARGUMENT_CONFIG='1'
            shift
            ;;

        --upgrade|-upgrade|upgrade)
            ARGUMENT_UPGRADE='1'
            shift
            ;;

        # other
        *)
            ARGUMENT_NONE='1'
            shift
            ;;

        --self-upgrade)
            ARGUMENT_SELF_UPGRADE='1'
            shift
            ;;
    esac
done

#############################################################################
# GENERAL FUNCTIONS
#############################################################################

function update_os {

    # update CentOS 7
    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 7" ]; then
    yum -y -q update
    fi

    # update CentOS 8+ and Fedora
    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 27" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 28" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 29" ]; then
    dnf -y -q update
    fi

    # update Debian and Ubuntu
    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 9" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 10" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 14.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 16.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.10" ]; then
    apt-get -qq update
    apt-get -y -qq upgrade
    fi
}

#############################################################################
# MANAGEMENT FUNCTIONS
#############################################################################

function serverbot_cron {

    echo
    echo "*** UPDATING CRONJOBS ***"

    # update cronjob for serverbot upgrade if enabled
    if [ "$SERVERBOT_UPGRADE" == 'yes' ]; then
        echo "[+] Updating cronjob for automatic upgrade"
        echo -e "# This cronjob activates automatic upgrade of serverbot on the chosen schedule\n\n${SERVER_UPGRADE_CRON} root /usr/local/bin/serverbot --upgrade" > /etc/cron.d/serverbot_auto_upgrade
    fi

    # update metrics cronjob if enabled
    if [ "$METRICS_ENABLED" == 'yes' ] && [ "$METRICS_TELEGRAM" == 'yes' ]; then
        echo "[+] Updating Metrics on Telegram cronjob"
        echo -e "# This cronjob activates Metrics on Telegram on the chosen schedule\n\n${METRICS_CRON} root /usr/local/bin/serverbot --metrics --telegram" > /etc/cron.d/serverbot_metrics_telegram
    elif [ "$METRICS_ENABLED" == 'yes' ] && [ "$METRICS_EMAIL" == 'yes' ]; then
        echo "[+] Updating Metrics on email cronjob"
        echo -e "# This cronjob activates Metrics on email on the chosen schedule\n\n${METRICS_CRON} root /usr/local/bin/serverbot --metrics --email" > /etc/cron.d/serverbot_metrics_email
    fi

    # update alert cronjob if enabled
    if [ "$ALERT_ENABLED" == 'yes' ] && [ "$ALERT_TELEGRAM" == 'yes' ]; then
        echo "[+] Updating Alert on Telegram cronjob"
        echo -e "# This cronjob activates Alert on Telegram on the chosen schedule\n\n${ALERT_CRON} root /usr/local/bin/serverbot --alert --telegram" > /etc/cron.d/serverbot_alert_telegram
    elif [ "$ALERT_ENABLED" == 'yes' ] && [ "$ALERT_EMAIL" == 'yes' ]; then
        echo "[+] Updating Alert on email cronjob"
        echo -e "# This cronjob activates Alert on email on the chosen schedule\n\n${ALERT_CRON} root /usr/local/bin/serverbot --alert --email" > /etc/cron.d/serverbot_alert_email   
    fi

    # update updates cronjob if enabled
    if [ "$UPDATES_ENABLED" == 'yes' ] && [ "$UPDATES_TELEGRAM" == 'yes' ]; then
        echo "[+] Updating Updates on Telegram cronjob"
        echo -e "# This cronjob activates Updates on Telegram on the the chosen schedule\n\n${UPDATES_CRON} root /usr/local/bin/serverbot --updates --telegram" > /etc/cron.d/serverbot_updates_telegram
    elif [ "$UPDATES_ENABLED" == 'yes' ] && [ "$UPDATES_EMAIL" == 'yes' ]; then
        echo "[+] Updating Updates on email cronjob"
        echo -e "# This cronjob activates Updates on email on the the chosen schedule\n\n${UPDATES_CRON} root /usr/local/bin/serverbot --updates --email" > /etc/cron.d/serverbot_updates_email
    fi

    # update login cronjob if enabled
    if [ "$LOGIN_ENABLED" == 'yes' ] && [ "$LOGIN_TELEGRAM" == 'yes' ]; then
        echo "[+] Updating Login on Telegram cronjob"
        echo -e "# This cronjob activates Login on Telegram on the the chosen schedule\n\n${LOGIN_CRON} root /usr/local/bin/serverbot --login --telegram" > /etc/cron.d/serverbot_login_telegram
    elif [ "$LOGIN_ENABLED" == 'yes' ] && [ "$LOGIN_EMAIL" == 'yes' ]; then
        echo "[+] Updating Login on email cronjob"
        echo -e "# This cronjob activates Login on email on the the chosen schedule\n\n${LOGIN_CRON} root /usr/local/bin/serverbot --login --email" > /etc/cron.d/serverbot_login_email
    fi

    # update outage cronjob if enabled
    if [ "$OUTAGE_ENABLED" == 'yes' ] && [ "$OUTAGE_TELEGRAM" == 'yes' ]; then
        echo "[+] Updating Outage on Telegram cronjob"
        echo -e "# This cronjob activates Outage on Telegram on the the chosen schedule\n\n${OUTAGE_CRON} root /usr/local/bin/serverbot --outage --telegram" > /etc/cron.d/serverbot_outage_telegram
    elif [ "$OUTAGE_ENABLED" == 'yes' ] && [ "$OUTAGE_EMAIL" == 'yes' ]; then
        echo "[+] Updating Outage on email cronjob"
        echo -e "# This cronjob activates Outage on email on the the chosen schedule\n\n${OUTAGE_CRON} root /usr/local/bin/serverbot --outage --email" > /etc/cron.d/serverbot_outage_email
    fi

    # update backup cronjob if enabled
    if [ "$BACKUP_ENABLED" == 'yes' ]; then
        echo "[+] Updating Backup cronjob"
        echo -e "# This cronjob activates Backup on the the chosen schedule\n\n${BACKUP_CRON} root /usr/local/bin/serverbot --backup" > /etc/cron.d/serverbot_backup
    fi

    # restart cron
    echo "[+] Restarting the cron service..."
    systemctl restart cron
    echo
    exit 0
}

function serverbot_upgrade {

    # create temp file for update
    TMP_INSTALL="$(mktemp)"

    # get most recent install script
    wget -q https://raw.githubusercontent.com/onnozel/serverbot/master/serverbot.sh -O "${TMP_INSTALL}"

    # set permissions on install script
    chmod 700 "${TMP_INSTALL}"

    # execute install script
    /bin/bash "${TMP_INSTALL}" --self-upgrade

    # remove temporary file
    rm "${TMP_INSTALL}"
}

function serverbot_self_upgrade {

    # During normal installation, only one pair of token and chat ID will be
    # asked and used. If you want to use multiple Telegram Bots for the
    # different roles, add the tokens and chat IDs in the below variables.
    # Please note that you have to set them *all* (even the ones you don't use)
    # for them to work.

    # this function is used both for installing and updating serverbot
    # if serverbot.conf exists, serverbot will be updates. if serverbot.conf doesn't
    # exist, serverbot will be installed.

    # check whether requirements are met
    echo
    requirement_root
    requirement_os
    requirement_internet

    # gather configuration settings if serverbot.conf is absent, otherwise use serverbot.conf
    if [ -f /etc/serverbot/serverbot.conf ]; then
        source /etc/serverbot/serverbot.conf

        # Notify user that all configuration steps will be skipped
        echo "[i] Info: existing configuration found, skipping creation..."
        echo "[i] Info: skipping gathering tokens..."
        echo "[i] Info: skipping gathering chat IDs..."
        echo "[i] Info: skipping adding configuration file..."
        echo "[i] Info: skipping adding tokens and IDs to configuration..."
        echo "[i] Info: skipping adding cronjobs to system..."
    else
        echo "[i] Info: no existing configuration found, installing serverbot..."

        # update os
        echo "[+] Installing dependencies..."
        update_os

        # install dependencies on CentOS 7
        if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 7" ]; then
            yum -y -q install wget bc
        fi

        # install dependencies on CentOS 8+ and Fedora
        if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 8" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 27" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 28" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 29" ]; then
            dnf -y -q install wget bc
        fi

        # install dependencies on Debian and Ubuntu
        if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 8" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 9" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 10" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 14.04" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 16.04" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.04" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.10" ]; then
            apt-get -y -qq install aptitude bc curl
        fi

        # optionally configure method telegram
        while true
            do
                read -r -p '[?] Configure method Telegram? (yes/no): ' TELEGRAM_CONFIGURE
                [ "${TELEGRAM_CONFIGURE}" = "yes" ] || [ "${TELEGRAM_CONFIGURE}" = "no" ] && break
                echo
                echo "[!] Error: please type yes or no and press enter to continue."
                echo
            done

        if [ "${TELEGRAM_CONFIGURE}" == 'yes' ]; then
            read -r -p '[?] Enter telegram bot token: ' TELEGRAM_TOKEN
            read -r -p '[?] Enter telegram chat ID:   ' TELEGRAM_CHAT_ID

            # Use provided token and chat ID in corresponding variables
            METRICS_TOKEN="${TELEGRAM_TOKEN}"
            METRICS_CHAT="${TELEGRAM_CHAT_ID}"
            ALERT_TOKEN="${TELEGRAM_TOKEN}"
            ALERT_CHAT="${TELEGRAM_CHAT_ID}"
            UPDATES_TOKEN="${TELEGRAM_TOKEN}"
            UPDATES_CHAT="${TELEGRAM_CHAT_ID}"
            LOGIN_TOKEN="${TELEGRAM_TOKEN}"
            LOGIN_CHAT="${TELEGRAM_CHAT_ID}"
            OUTAGE_TOKEN="${TELEGRAM_TOKEN}"
            OUTAGE_CHAT="${TELEGRAM_CHAT_ID}"
        fi

        # add serverbot configuration file to /etc/serverbot
        echo "[+] Adding configuration file to system..."
        mkdir -m 755 /etc/serverbot
        wget -q https://raw.githubusercontent.com/onnozel/serverbot/master/serverbot.conf -O /etc/serverbot/serverbot.conf
        chmod 640 /etc/serverbot/serverbot.conf

        # add operating system information
        echo "[+] Adding system information to configuration file..."
        sed -i s%'operating_system_here'%"${OPERATING_SYSTEM}"%g /etc/serverbot/serverbot.conf
        sed -i s%'operating_system_version_here'%"${OPERATING_SYSTEM_VERSION}"%g /etc/serverbot/serverbot.conf

        # add Telegram access tokens and chat IDs
        if [ "${TELEGRAM_CONFIGURE}" == 'yes' ]; then
            echo "[+] Adding access token and chat ID to bots..."
            sed -i s%'auto_upgrade_here'%"${AUTO_UPGRADE}"%g /etc/serverbot/serverbot.conf
            sed -i s%'metrics_activate_here'%"${METRICS_ENABLED}"%g /etc/serverbot/serverbot.conf
            sed -i s%'metrics_token_here'%"${METRICS_TOKEN}"%g /etc/serverbot/serverbot.conf
            sed -i s%'metrics_id_here'%"${METRICS_CHAT}"%g /etc/serverbot/serverbot.conf
            sed -i s%'alert_activate_here'%"${ALERT_ENABLED}"%g /etc/serverbot/serverbot.conf
            sed -i s%'alert_token_here'%"${ALERT_TOKEN}"%g /etc/serverbot/serverbot.conf
            sed -i s%'alert_id_here'%"${ALERT_CHAT}"%g /etc/serverbot/serverbot.conf
            sed -i s%'updates_activate_here'%"${UPDATES_ENABLED}"%g /etc/serverbot/serverbot.conf
            sed -i s%'updates_token_here'%"${UPDATES_TOKEN}"%g /etc/serverbot/serverbot.conf
            sed -i s%'updates_id_here'%"${UPDATES_CHAT}"%g /etc/serverbot/serverbot.conf
            sed -i s%'login_activate_here'%"${LOGIN_ENABLED}"%g /etc/serverbot/serverbot.conf
            sed -i s%'login_token_here'%"${LOGIN_TOKEN}"%g /etc/serverbot/serverbot.conf
            sed -i s%'login_id_here'%"${LOGIN_CHAT}"%g /etc/serverbot/serverbot.conf
            sed -i s%'outage_activate_here'%"${OUTAGE_ENABLED}"%g /etc/serverbot/serverbot.conf
            sed -i s%'outage_token_here'%"${OUTAGE_TOKEN}"%g /etc/serverbot/serverbot.conf
            sed -i s%'outage_id_here'%"${OUTAGE_CHAT}"%g /etc/serverbot/serverbot.conf
        fi
    fi

    # install latest version serverbot
    echo "[+] Installing latest version of serverbot..."
    wget -q https://raw.githubusercontent.com/onnozel/serverbot/master/serverbot.sh -O /usr/local/bin/serverbot
    chmod 755 /usr/local/bin/serverbot

    # creating or updating cronjobs
    /bin/bash /usr/local/bin/serverbot --config
}

#############################################################################
# REQUIREMENT FUNCTIONS
#############################################################################

function requirement_root {

    # checking whether the script runs as root
    if [ "$EUID" -ne 0 ]; then
        echo
        echo '[!] Error: this script should run with root privileges.'
        echo
        exit 1
    else
        echo '[i] Info: script has correct privileges...'
    fi
}

function requirement_os {

    # checking whether supported operating system is installed
    # source /etc/os-release to use variables
    if [ -f /etc/os-release ]; then
        source /etc/os-release

        # Put distro name and version in variables
        OPERATING_SYSTEM="${NAME}"
        OPERATING_SYSTEM_VERSION="${VERSION_ID}"

        # check all supported combinations of OS and version
        if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 7" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 8" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 27" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 28" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 29" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 8" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 9" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 10" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 14.04" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 16.04" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.04" ] || \
        [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.10" ]; then
            if [ "$ARGUMENT_UPGRADE" == '1' ]; then
                echo '[i] Info: operating system is supported...'
            fi
        else
            echo
            echo '[!] Error: this operating system is not supported.'
            echo
            exit 1
        fi
    else
        echo
        echo '[!] Error: this operating system is not supported.'
        echo
        exit 1
    fi
}

function requirement_internet {

    # checking internet connection
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo '[i] Info: is connected to the internet...'
    else
        echo
        echo '[!] Error: access to the internet is required.'
        echo
        exit 1
    fi
}

#############################################################################
# GATHER FUNCTIONS
#############################################################################

function gather_server_information {

    # server information
    HOSTNAME="$(uname -n)"
    UPTIME="$(uptime -p)"
}

function gather_metrics_cpu {

    # cpu and load metrics
    CORE_AMOUNT="$(grep -c 'cpu cores' /proc/cpuinfo)"
    MAX_LOAD_SERVER="${CORE_AMOUNT}.00"
    COMPLETE_LOAD="$(< /proc/loadavg awk '{print $1" "$2" "$3}')"
    CURRENT_LOAD="$(< /proc/loadavg awk '{print $3}')"
    CURRENT_LOAD_PERCENTAGE="$(echo "(${CURRENT_LOAD}/${MAX_LOAD_SERVER})*100" | bc -l)"
    CURRENT_LOAD_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_LOAD_PERCENTAGE}" | tr -d '%'))"
}

function gather_metrics_memory {

    # check os
    requirement_os

    # use older format in free when Debian 8 or Ubuntu 14.04 is used
    if [ "${OPERATING_SYSTEM} ${OPERATING_SYSTEM_VERSION}" == "Debian GNU/Linux 8" ] || \
    [ "${OPERATING_SYSTEM} ${OPERATING_SYSTEM_VERSION}" == "Ubuntu 14.04" ]; then
        TOTAL_MEMORY="$(free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_MEMORY="$(free -m | awk '/^Mem/ {print $6}')"
        CACHED_MEMORY="$(free -m | awk '/^Mem/ {print $7}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_MEMORY}-${CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    fi

    # use newer format in free when CentOS 7+, Debian 9+ or Ubuntu 16.04+ is used
    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 7" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 27" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 28" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 29" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 9" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 10" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 16.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.10" ]; then
        TOTAL_MEMORY="$(free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_CACHED_MEMORY="$(free -m | awk '/^Mem/ {print $6}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    fi
}

function gather_metrics_disk {

    # file system metrics
    TOTAL_DISK_SIZE="$(df -h / --output=size -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_USAGE="$(df -h / --output=used -x tmpfs -x devtmpfs | sed -n '2 p' | tr -d ' ')"
    CURRENT_DISK_PERCENTAGE="$(df / --output=pcent -x tmpfs -x devtmpfs | tr -dc '0-9')"
}

function gather_metrics_threshold {

    # strip '%' of thresholds in serverbot.conf
    THRESHOLD_LOAD_NUMBER="$(echo "${THRESHOLD_LOAD}" | tr -d '%')"
    THRESHOLD_MEMORY_NUMBER="$(echo "${THRESHOLD_MEMORY}" | tr -d '%')"
    THRESHOLD_DISK_NUMBER="$(echo "${THRESHOLD_DISK}" | tr -d '%')"
}

function gather_updates {

    # check os
    requirement_os

    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 7" ]; then
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(yum check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    fi

    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "CentOS Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 27" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 28" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Fedora 29" ]; then
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(dnf check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    fi

    if [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 8" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 9" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Debian GNU/Linux 10" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 14.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 16.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.04" ] || \
    [ "$OPERATING_SYSTEM $OPERATING_SYSTEM_VERSION" == "Ubuntu 18.10" ]; then
        # update repository
        apt-get -qq update
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(aptitude -F "%p" search '~U')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    fi
}

#############################################################################
# FEATURE FUNCTIONS
#############################################################################

function feature_not_yet_implemented {
    echo "Oops! This function has not been implemented yet!"
    exit 0
}

function feature_metrics_cli {

    # output server metrics to shell and exit
    echo
    echo "HOST:     ${HOSTNAME}"
    echo "UPTIME:   ${UPTIME}"
    echo "LOAD:     ${COMPLETE_LOAD}"
    echo "MEMORY:   ${USED_MEMORY}M / ${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)"
    echo "DISK:     ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)"
    exit 0
}

function feature_metrics_telegram {

    # add values to method_telegram variables
    TELEGRAM_CHAT_ID="${METRICS_CHAT}"
    TELEGRAM_URL="${METRICS_URL}"

    # create message for telegram
    TELEGRAM_MESSAGE="$(echo -e "*Host*:        ${HOSTNAME}\\n*UPTIME*:  ${UPTIME}\\n\\n*Load*:         ${COMPLETE_LOAD}\\n*Memory*:  ${USED_MEMORY} M / ${TOTAL_MEMORY} M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)\\n*Disk*:          ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)")"

    # call method_telegram
    method_telegram

    # exit when done
    exit 0
}

function feature_alert_cli {

    # check whether the current server load exceeds the threshold and alert if true
    # and output server alert status to shell
    echo
    if [ "$CURRENT_LOAD_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_LOAD_NUMBER" ]; then
        echo -e "[!] SERVER LOAD:\\tA current server load of ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% exceeds the threshold of ${THRESHOLD_LOAD}."
    else
        echo -e "[i] SERVER LOAD:\\tA current server load of ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% does not exceed the threshold of ${THRESHOLD_LOAD}."
    fi

    if [ "$CURRENT_MEMORY_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_MEMORY_NUMBER" ]; then
        echo -e "[!] SERVER MEMORY:\\tA current memory usage of ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% exceeds the threshold of ${THRESHOLD_MEMORY}."
    else
        echo -e "[i] SERVER MEMORY:\\tA current memory usage of ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% does not exceed the threshold of ${THRESHOLD_MEMORY}."
    fi

    if [ "$CURRENT_DISK_PERCENTAGE" -ge "$THRESHOLD_DISK_NUMBER" ]; then
        echo -e "[!] DISK USAGE:\\t\\tA current disk usage of ${CURRENT_DISK_PERCENTAGE}% exceeds the threshold of ${THRESHOLD_DISK}."
    else
        echo -e "[i] DISK USAGE:\\t\\tA current disk usage of ${CURRENT_DISK_PERCENTAGE}% does not exceed the threshold of ${THRESHOLD_DISK}."
    fi

    # exit when done
    exit 0
}

function feature_alert_telegram {

    # add values to method_telegram variables
    TELEGRAM_CHAT_ID="${ALERT_CHAT}"
    TELEGRAM_URL="${ALERT_URL}"

    # check whether the current server load exceeds the threshold and alert if true
    if [ "$CURRENT_LOAD_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_LOAD_NUMBER" ]; then
        # create message for Telegram
        TELEGRAM_MESSAGE="\xE2\x9A\xA0 *ALERT: SERVER LOAD*\\n\\nThe server load (${CURRENT_LOAD_PERCENTAGE_ROUNDED}%) on *${HOSTNAME}* exceeds the threshold of ${THRESHOLD_LOAD}\\n\\n*Load average:*\\n${COMPLETE_LOAD}"

        # call method_telegram
        method_telegram
    fi

    # check whether the current server memory usage exceeds the threshold and alert if true
    if [ "$CURRENT_MEMORY_PERCENTAGE_ROUNDED" -ge "$THRESHOLD_MEMORY_NUMBER" ]; then
        # create message for Telegram
        TELEGRAM_MESSAGE="\xE2\x9A\xA0 *ALERT: SERVER MEMORY*\\n\\nMemory usage (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%) on *${HOSTNAME}* exceeds the threshold of ${THRESHOLD_MEMORY}\\n\\n*Memory usage:*\\n$(free -m -h)"

        # call method_telegram
        method_telegram
    fi

    # check whether the current disk usaged exceeds the threshold and alert if true
    if [ "$CURRENT_DISK_PERCENTAGE" -ge "$THRESHOLD_DISK_NUMBER" ]; then
        # create message for Telegram
        TELEGRAM_MESSAGE="\xE2\x9A\xA0 *ALERT: FILE SYSTEM*\\n\\nDisk usage (${CURRENT_DISK_PERCENTAGE}%) on *${HOSTNAME}* exceeds the threshold of ${THRESHOLD_DISK}\\n\\n*Filesystem info:*\\n$(df -h)"

        # call method_telegram
        method_telegram
    fi

    # exit when done
    exit 0
}

function feature_updates_cli {

    echo
    # notify user when there are no updates
    if [ -z "$AVAILABLE_UPDATES" ]; then
        echo
        echo "There are no updates available."
        echo
    else
        # notify user when there are updates available
        echo
        echo "The following updates are available:"
        echo
        echo "${AVAILABLE_UPDATES}"
        echo
    fi

    # exit when done
    exit 0
}

function feature_updates_telegram {

    # do nothing if there are no updates
    if [ -z "$AVAILABLE_UPDATES" ]; then
        exit 0
    else
        # if update list length is less than 4000 characters, then sent update list
        if [ "$LENGTH_UPDATES" -lt "4000" ]; then
            TELEGRAM_MESSAGE="There are updates available on *${HOSTNAME}*:\n\n${AVAILABLE_UPDATES}"
        fi

        # if update list length is greater than 4000 characters, don't sent update list
        if [ "$LENGTH_UPDATES" -gt "4000" ]; then
            TELEGRAM_MESSAGE="There are updates available on *${HOSTNAME}*. Unfortunately, the list with updates is too large for Telegram. Please update your server as soon as possible."
        fi

        # call method_telegram
        method_telegram
    fi

    # exit when done
    exit 0
}

#############################################################################
# METHOD FUNCTIONS
#############################################################################

function method_telegram {

    # give error when telegram is unavailable
    if [ "${METHOD_TELEGRAM}" == 'disabled' ]; then
        echo
        echo '[!] Error: method Telegram is not available without Serverbot configuration file.'
        echo
        exit 0
    fi

    # create payload for Telegram
    TELEGRAM_PAYLOAD="chat_id=${TELEGRAM_CHAT_ID}&text=${TELEGRAM_MESSAGE}&parse_mode=Markdown&disable_web_page_preview=true"

    # sent payload to Telegram API and exit
    curl -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${TELEGRAM_PAYLOAD}" "${TELEGRAM_URL}" > /dev/null 2>&1 &
}

function method_email {

    # planned for version 1.1
    echo '[!] Error: method e-mail is not available yet.'
}

#############################################################################
# MAIN FUNCTION
#############################################################################

function serverbot_main {

    ### SOME WAY OF CHECKING VALIDITY OF INPUT HERE ###

    # option cron
    if [ "$ARGUMENT_CRON" == '1' ]; then
        serverbot_cron
    # option upgrade
    elif [ "$ARGUMENT_UPGRADE" == '1' ]; then
        serverbot_upgrade
    # feature metrics; method cli
    elif [ "$ARGUMENT_METRICS" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        gather_server_information
        gather_metrics_cpu
        gather_metrics_memory
        gather_metrics_disk
        feature_metrics_cli
    # feature metrics; method Telegram
    elif [ "$ARGUMENT_METRICS" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        gather_server_information
        gather_metrics_cpu
        gather_metrics_memory
        gather_metrics_disk
        feature_metrics_telegram
    # feature metrics; method email
    elif [ "$ARGUMENT_METRICS" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # feature alert; method cli
    elif [ "$ARGUMENT_ALERT" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        gather_server_information
        gather_metrics_cpu
        gather_metrics_memory
        gather_metrics_disk
        gather_metrics_threshold
        feature_alert_cli
    # feature alert; method telegram
    elif [ "$ARGUMENT_ALERT" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        gather_server_information
        gather_metrics_cpu
        gather_metrics_memory
        gather_metrics_disk
        gather_metrics_threshold
        feature_alert_telegram
    # feature alert; method email
    elif [ "$ARGUMENT_ALERT" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # feature updates; method cli
    elif [ "$ARGUMENT_UPDATES" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        gather_updates
        feature_updates_cli
    # feature updates; method telegram
    elif [ "$ARGUMENT_UPDATES" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        gather_server_information
        gather_updates
        feature_updates_telegram
    # feature updates; method email
    elif [ "$ARGUMENT_UPDATES" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # feature login; method cli
    elif [ "$ARGUMENT_LOGIN" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        feature_not_yet_implemented
    # feature login; method telegram
    elif [ "$ARGUMENT_LOGIN" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        feature_not_yet_implemented
    # feature login; method email
    elif [ "$ARGUMENT_LOGIN" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # feature outage; method cli
    elif [ "$ARGUMENT_OUTAGE" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        feature_not_yet_implemented
    # feature outage; method telegram
    elif [ "$ARGUMENT_OUTAGE" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        feature_not_yet_implemented
    # feature outage; method email
    elif [ "$ARGUMENT_OUTAGE" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method none
    elif [ "$ARGUMENT_BACKUP" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method cli
    elif [ "$ARGUMENT_BACKUP" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method telegram
    elif [ "$ARGUMENT_BACKUP" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method email
    elif [ "$ARGUMENT_BACKUP" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # feature sql; method none
    elif [ "$ARGUMENT_FILES" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method cli
    elif [ "$ARGUMENT_FILES" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method telegram
    elif [ "$ARGUMENT_FILES" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method email
    elif [ "$ARGUMENT_FILES" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # feature sql; method none
    elif [ "$ARGUMENT_SQL" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method cli
    elif [ "$ARGUMENT_SQL" == '1' ] && [ "$ARGUMENT_CLI" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method telegram
    elif [ "$ARGUMENT_SQL" == '1' ] && [ "$ARGUMENT_TELEGRAM" == '1' ]; then
        feature_not_yet_implemented
    # feature backup; method email
    elif [ "$ARGUMENT_SQL" == '1' ] && [ "$ARGUMENT_EMAIL" == '1' ]; then
        feature_not_yet_implemented
    # undefined argument given
    elif [ "$ARGUMENT_NONE" == '1' ]; then
        echo
        echo "serverbot: invalid option -- '${1}'"
        echo "Try 'serverbot --help' for more information."
        echo
        exit 1
    fi
}

#############################################################################
# CALL MAIN FUNCTION
#############################################################################

# call main function
serverbot_main
