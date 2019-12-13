#!/bin/bash

#############################################################################
# Version 1.2.0-UNSTABLE (20-10-2019)
#############################################################################

#############################################################################
# Copyright 2016-2019 Nozel/Sebas Veeke. Licenced under a Creative Commons
# Attribution-NonCommercial-ShareAlike 4.0 International License.
#
# See https://creativecommons.org/licenses/by-nc-sa/4.0/
#
# Contact:
# > e-mail      mail@nozel.org
# > GitHub      nozel-org
#############################################################################

#############################################################################
# VARIABLES
#############################################################################

# serverbot version
SERVERBOT_VERSION='1.2.0'

# check whether serverbot.conf is available and source it
if [ -f /etc/serverbot/serverbot.conf ]; then
    source /etc/serverbot/serverbot.conf
    # check whether method telegram has been configured
    if [ "${TELEGRAM_TOKEN}" == 'telegram_token_here' ]; then
        METHOD_TELEGRAM='disabled'
    fi
else
    # otherwise disable these options, features and methods
    SERVERBOT_CONFIG='disabled' # won't work without serverbot.conf
    METHOD_TELEGRAM='disabled' # won't work without serverbot.conf
    METHOD_EMAIL='disabled' # won't work without serverbot.conf

    # and use these default values for the alert threshold parameters
    THRESHOLD_LOAD='90%'
    THRESHOLD_MEMORY='80%'
    THRESHOLD_DISK='80%'

    # and default to stable branch
    SERVERBOT_BRANCH='unstable'
fi

#############################################################################
# ARGUMENTS
#############################################################################

# save amount of arguments for validity check
ARGUMENTS="${#}"

# populate validation variables with zero
ARGUMENT_OPTION='0'
ARGUMENT_FEATURE='0'
ARGUMENT_METHOD='0'

# enable help, version and a cli option
while test -n "$1"; do
    case "$1" in
        # options
        --version|-version|version|--v|-v)
            ARGUMENT_VERSION='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --help|-help|help|--h|-h)
            ARGUMENT_HELP='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --cron)
            ARGUMENT_CRON='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --validate)
            ARGUMENT_VALIDATE='1'
            ARGUMENT_OPTIONS='1'
            shift
            ;;

        --install)
            ARGUMENT_INSTALL='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --upgrade)
            ARGUMENT_UPGRADE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --silent-upgrade)
            ARGUMENT_SILENT_UPGRADE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --self-upgrade)
            ARGUMENT_SELF_UPGRADE='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        --uninstall)
            ARGUMENT_UNINSTALL='1'
            ARGUMENT_OPTION='1'
            shift
            ;;

        # features
        --overview|overview)
            ARGUMENT_OVERVIEW='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        --metrics|metrics)
            ARGUMENT_METRICS='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        --alert|alert)
            ARGUMENT_ALERT='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        --updates|updates)
            ARGUMENT_UPDATES='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        --eol|eol)
            ARGUMENT_EOL='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        # methods
        --cli|cli)
            ARGUMENT_CLI='1'
            ARGUMENT_METHOD='1'
            shift
            ;;

        --telegram|telegram)
            ARGUMENT_TELEGRAM='1'
            ARGUMENT_METHOD='1'
            shift
            ;;

        --email|email)
            ARGUMENT_EMAIL='1'
            ARGUMENT_METHOD='1'
            shift
            ;;

        # other
        *)
            ARGUMENT_NONE='1'
            shift
            ;;
    esac
done

#############################################################################
# ERROR FUNCTIONS
#############################################################################

function error_invalid_option {
    echo 'serverbot: invalid option'
    echo "Use 'serverbot --help' for a list of valid arguments."
    exit 1
}

function error_wrong_amount_of_arguments {
    echo 'serverbot: wrong amount of arguments'
    echo "Use 'serverbot --help' for a list of valid arguments."
    exit 1
}

function error_not_yet_implemented {
    echo 'serverbot: this feature has not been implemented yet.'
    exit 1
}

function error_os_not_supported {
    echo 'serverbot: operating system is not supported.'
    exit 1
}

function error_not_available {
    echo 'serverbot: option or method is not available without the serverbot configuration file.'
    exit 1
}

function error_no_feature_and_method {
    echo 'serverbot: feature requires a method and vice versa'
    echo "Use 'serverbot --help' for a list of valid arguments."
    exit 1
}

function error_options_cannot_be_combined {
    echo 'serverbot: options cannot be used with features or methods'
    echo "Use 'serverbot --help' for a list of valid arguments."
    exit 1
}

function error_no_root_privileges {
    echo 'serverbot: you need to be root to perform this command'
    echo "use 'sudo serverbot', 'sudo -s' or run serverbot as root user."
    exit 1
}

function error_no_internet_connection {
    echo 'serverbot: access to the internet is required.'
    exit 1
}

function error_type_yes_or_no {
    echo "serverbot: type yes or no and press enter to continue."
}

function error_method_telegram_disabled {
    echo "serverbot: method telegram is unavailable without correct configuration in serverbot configuration file."
    exit 1
}

function error_method_email_disabled {
    echo "serverbot: method email is unavailable without correct configuration in serverbot configuration file."
    exit 1
}

#############################################################################
# REQUIREMENT FUNCTIONS
#############################################################################

function requirement_argument_validity {
    # features require methods and vice versa
    if [ "${ARGUMENT_FEATURE}" == '1' ] && [ "${ARGUMENT_METHOD}" == '0' ]; then
        error_no_feature_and_method
    elif [ "${ARGUMENT_FEATURE}" == '0' ] && [ "${ARGUMENT_METHOD}" == '1' ]; then
        error_no_feature_and_method
    # amount of arguments less than one or more than two result in error
    elif [ "${ARGUMENTS}" -eq '0' ] || [ "${ARGUMENTS}" -gt '2' ]; then
        error_wrong_amount_of_arguments
    # options are incompatible with features
    elif [ "${ARGUMENT_OPTION}" == '1' ] && [ "${ARGUMENT_FEATURE}" == '1' ]; then
        error_options_cannot_be_combined
    # options are incompatible with methods
    elif [ "${ARGUMENT_OPTION}" == '1' ] && [ "${ARGUMENT_METHOD}" == '1' ]; then
        error_options_cannot_be_combined
    elif [ "${ARGUMENT_TELEGRAM}" == '1' ] && [ "${METHOD_TELEGRAM}" == 'disabled' ]; then
        error_method_telegram_disabled
    elif [ "${ARGUMENT_EMAIL}" == '1' ] && [ "${METHOD_EMAIL}" == 'disabled' ]; then
        error_method_email_disabled
    fi
}

function requirement_root {
    # check whether the script runs as root
    if [ "$EUID" -ne 0 ]; then
        error_no_root_privileges
    fi
}

function requirement_os {
    # check whether supported package manager is installed and populate relevant variables
    if [ "$(command -v dnf)" ]; then
        PACKAGE_MANAGER='dnf'
    elif [ "$(command -v yum)" ]; then
        PACKAGE_MANAGER='yum'
    elif [ "$(command -v apt-get)" ]; then
        PACKAGE_MANAGER='apt-get'
    elif [ "$(command -v pkg)" ]; then
        PACKAGE_MANAGER='pkg'
    #elif [ "$(command -v apk)" ]; then
        #PACKAGE_MANAGER='apk'
    else
        error_os_not_supported
    fi

    # check whether supported service manager is installed and populate relevant variables
    # systemctl
    if [ "$(command -v systemctl)" ]; then
        SERVICE_MANAGER='systemctl'
    # service
    elif [ "$(command -v service)" ]; then
        SERVICE_MANAGER='service'
    # openrc
    elif [ "$(command -v rc-service)" ]; then
        SERVICE_MANAGER='openrc'
    else
        error_os_not_supported
    fi
}

function requirement_internet {
    # check internet connection
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo '[i] Info: device is connected to the internet...'
    else
        error_no_internet_connection
    fi
}

#############################################################################
# MANAGEMENT FUNCTIONS
#############################################################################

function serverbot_version {
    echo "Serverbot ${SERVERBOT_VERSION}"
    echo "Copyright (C) 2016-2019 Nozel."
    echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
    echo
    echo "Written by Sebas Veeke"
}

function serverbot_help {
    echo "Usage:"
    echo " serverbot [feature]... [method]..."
    echo " serverbot [option]..."
    echo
    echo "Features:"
    echo " --overview        Show server overview"
    echo " --metrics         Show server metrics"
    echo " --alert           Show server alert status"
    echo " --updates         Show available server updates"
    echo " --eol             Show end-of-life status of operating system"
    echo
    echo "Methods:"
    echo " --cli             Output [feature] to command line"
    echo " --telegram        Output [feature] to Telegram bot"
    #echo "--email           Output [feature] to e-mail"
    echo
    echo "Options:"
    echo " --cron            Effectuate cron changes from serverbot config"
    echo " --validate        Check validity of serverbot.conf"
    echo " --install         Installs serverbot on the system and unlocks all features"
    echo " --upgrade         Upgrade serverbot to the latest stable version"
    echo " --uninstall       Uninstalls serverbot from the system"
    echo " --help            Display this help and exit"
    echo " --version         Display version information and exit"
}

function serverbot_cron {
    # function requirements
    requirement_root
    serverbot_validate

    # return error when config file isn't installed on the system
    if [ "${SERVERBOT_CONFIG}" == 'disabled' ]; then
        error_not_available
    fi

    echo '*** UPDATING CRONJOBS ***'
    # remove cronjobs so automated tasks can also be deactivated
    echo '[-] Removing old serverbot cronjobs...'
    rm -f /etc/cron.d/serverbot_*
    # update cronjobs automated tasks
    if [ "${SERVERBOT_UPGRADE}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated upgrade of serverbot...'
        echo -e "# This cronjob activates automatic upgrade of serverbot on the chosen schedule\n${SERVERBOT_UPGRADE_CRON} root /usr/bin/serverbot --silent-upgrade" > /etc/cron.d/serverbot_upgrade
    fi
    if [ "${OVERVIEW_TELEGRAM}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated server overviews on Telegram...'
        echo -e "# This cronjob activates automated server overview on Telegram on the chosen schedule\n${OVERVIEW_CRON} root /usr/bin/serverbot --overview --telegram" > /etc/cron.d/serverbot_overview_telegram
    fi
    #if [ "${OVERVIEW_EMAIL}" == 'yes' ]; then
    #    echo '[+] Updating cronjob for automated server overviews on email...'
    #    echo -e "# This cronjob activates automated server overview on email on the chosen schedule\n${OVERVIEW_CRON} root /usr/bin/serverbot --overview --email" > /etc/cron.d/serverbot_overview_email
    #fi
    if [ "${METRICS_TELEGRAM}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated server metrics on Telegram...'
        echo -e "# This cronjob activates automated server metrics on Telegram on the chosen schedule\n${METRICS_CRON} root /usr/bin/serverbot --metrics --telegram" > /etc/cron.d/serverbot_metrics_telegram
    fi
    #if [ "${METRICS_EMAIL}" == 'yes' ]; then
    #    echo '[+] Updating cronjob for automated server metrics on email...'
    #    echo -e "# This cronjob activates automated server metrics on email on the chosen schedule\n${METRICS_CRON} root /usr/bin/serverbot --metrics --email" > /etc/cron.d/serverbot_metrics_email
    #fi
    if [ "${ALERT_TELEGRAM}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated server health alerts on Telegram...'
        echo -e "# This cronjob activates automated server health alerts on Telegram on the chosen schedule\n${ALERT_CRON} root /usr/bin/serverbot --alert --telegram" > /etc/cron.d/serverbot_alert_telegram
    fi
    #if [ "${ALERT_EMAIL}" == 'yes' ]; then
    #    echo '[+] Updating cronjob for automated server health alerts on email...'
    #    echo -e "# This cronjob activates automated server health alerts alert on email on the chosen schedule\n${ALERT_CRON} root /usr/bin/serverbot --alert --email" > /etc/cron.d/serverbot_alert_email   
    #fi
    if [ "${UPDATES_TELEGRAM}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated update overviews on Telegram...'
        echo -e "# This cronjob activates automated update overviews on Telegram on the the chosen schedule\n${UPDATES_CRON} root /usr/bin/serverbot --updates --telegram" > /etc/cron.d/serverbot_updates_telegram
    fi
    #if [ "${UPDATES_EMAIL}" == 'yes' ]; then
    #    echo '[+] Updating cronjob for automated update overviews on email...'
    #    echo -e "# This cronjob activates automated update overviews on email on the the chosen schedule\n\n${UPDATES_CRON} root /usr/bin/serverbot --updates --email" > /etc/cron.d/serverbot_updates_email
    #fi
    if [ "${EOL_TELEGRAM}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated EOL warnings on Telegram...'
        echo -e "# This cronjob activates automated EOL warnings on Telegram on the the chosen schedule\n${CLI_CRON} root /usr/bin/serverbot --eol --telegram" > /etc/cron.d/serverbot_eol_telegram
    fi
    #if [ "${EOL_EMAIL}" == 'yes' ]; then
    #    echo '[+] Updating cronjob for automated EOL warnings on email...'
    #    echo -e "# This cronjob activates automated EOL warnings on e-mail on the the chosen schedule\n${CLI_CRON} root /usr/bin/serverbot --eol --email" > /etc/cron.d/serverbot_eol_email
    #fi

    # give user feedback when all automated tasks are disabled
    if [ "${SERVERBOT_UPGRADE}" != 'yes' ] && \
    [ "${OVERVIEW_TELEGRAM}" != 'yes' ] && \
    [ "${METRICS_TELEGRAM}" != 'yes' ] && \
    [ "${ALERT_TELEGRAM}" != 'yes' ] && \
    [ "${UPDATES_TELEGRAM}" != 'yes' ] && \
    [ "${EOL_TELEGRAM}" != 'yes' ]; then
        echo '[i] All automated tasks are disabled, no cronjobs to update...'
        exit 0
    fi

    # restart cron to really effectuate the new cronjobs
    echo '[+] Restarting the cron service...'
    if [ "${SERVICE_MANAGER}" == "systemctl" ] && [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        systemctl restart crond.service
    elif [ "${SERVICE_MANAGER}" == "systemctl" ] && [ "${PACKAGE_MANAGER}" == "yum" ]; then
        systemctl restart crond.service
    elif [ "${SERVICE_MANAGER}" == "systemctl" ] && [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        systemctl restart cron.service
    elif [ "${SERVICE_MANAGER}" == "service" ] && [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        service cron restart
    #elif [ "${SERVICE_MANAGER}" == "rc-service" ] && [ "${PACKAGE_MANAGER}" == "apk" ]; then
    #    rc-service cron start # not sure if this is correct
    fi
    echo '[i] Done!'
    exit 0
}

function serverbot_validate {
    # function requirements
    requirement_root

    # return error when config file isn't installed on the system
    if [ "${SERVERBOT_CONFIG}" == 'disabled' ]; then
        error_not_available
    fi

    echo '*** VALIDATING SERVERBOT.CONF ***'
    # create temporary file for serverbot.conf
    echo '[+] Creating temporary file from /etc/serverbot/serverbot.conf...'
    TMP_VALIDATE="$(mktemp)"
    # remove all content beginning with '#', remove all white space and add to temporary file
    cat /etc/serverbot/serverbot.conf | cut -f1 -d"#" | sed '/^[[:space:]]*$/d' | tr -d '%' > "${TMP_VALIDATE}"
    # source temporary file so the variables can be validated
    source "${TMP_VALIDATE}"

    # validate config file (without cron and method specific config parameters)
    echo "[i] Note: cron and method configuration parameters will not be validated..."
    echo '[i] Validating temporary serverbot.conf...'
    VALIDATION_ERROR='0'
    if [ ! "${MAJOR_VERSION}" > '0' ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable MAJOR_VERSION should be a number."
    fi
    if { [ "${SERVERBOT_UPGRADE}" != 'yes' ] && [ "${SERVERBOT_UPGRADE}" != 'no' ]; } && [ ! -z "${SERVERBOT_UPGRADE}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable SERVERBOT_UPGRADE should be either 'yes' or 'no'."
    fi
    if { [ "${SERVERBOT_UPGRADE_TELEGRAM}" != 'yes' ] && [ "${SERVERBOT_UPGRADE_TELEGRAM}" != 'no' ]; } && [ ! -z "${SERVERBOT_UPGRADE_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable SERVERBOT_UPGRADE_TELEGRAM should be either 'yes' or 'no'."
    fi
    if { [ "${OVERVIEW_TELEGRAM}" != 'yes' ] && [ "${OVERVIEW_TELEGRAM}" != 'no' ]; } && [ ! -z "${OVERVIEW_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable OVERVIEW_TELEGRAM should be either 'yes' or 'no'."
    fi
    if { [ "${METRICS_TELEGRAM}" != 'yes' ] && [ "${METRICS_TELEGRAM}" != 'no' ]; } && [ ! -z "${METRICS_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable METRICS_TELEGRAM should be either 'yes' or 'no'."
    fi
    if { [ "${ALERT_TELEGRAM}" != 'yes' ] && [ "${ALERT_TELEGRAM}" != 'no' ]; } && [ ! -z "${ALERT_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable ALERT_TELEGRAM should be either 'yes' or 'no'."
    fi
    if { [ "${UPDATES_TELEGRAM}" != 'yes' ] && [ "${UPDATES_TELEGRAM}" != 'no' ]; } && [ ! -z "${UPDATES_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable UPDATES_TELEGRAM should be either 'yes' or 'no'."
    fi
    if { [ "${EOL_TELEGRAM}" != 'yes' ] && [ "${EOL_TELEGRAM}" != 'no' ]; } && [ ! -z "${EOL_TELEGRAM}" ]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable EOL_TELEGRAM should be either 'yes' or 'no'."
    fi
    if [[ "$(echo ${THRESHOLD_LOAD} | tr -d '%')" -lt '0' ]] || [[ "$(echo ${THRESHOLD_LOAD} | tr -d '%')" -gt '100' ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable THRESHOLD_LOAD should be between '0%' and '100%'."
    fi
    if [[ ! "$(echo ${THRESHOLD_LOAD} | tr -d '%')" =~ ^[[:digit:]] ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable THRESHOLD_LOAD should only contain numbers and '%'."
    fi
    if [[ "$(echo ${THRESHOLD_MEMORY} | tr -d '%')" -lt '0' ]] || [[ "$(echo ${THRESHOLD_MEMORY} | tr -d '%')" -gt '100' ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable THRESHOLD_MEMORY should be between '0%' and '100%'."
    fi
    if [[ ! "$(echo ${THRESHOLD_MEMORY} | tr -d '%')" =~ ^[[:digit:]] ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable THRESHOLD_MEMORY should only contain numbers and '%'."
    fi
    if [[ "$(echo ${THRESHOLD_DISK} | tr -d '%')" -lt '0' ]] || [[ "$(echo ${THRESHOLD_DISK} | tr -d '%')" -gt '100' ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable THRESHOLD_DISK should be between '0%' and '100%'."
    fi
    if [[ ! "$(echo ${THRESHOLD_DISK} | tr -d '%')" =~ ^[[:digit:]] ]]; then
        VALIDATION_ERROR='1'
        echo "[!] Validation error: variable THRESHOLD_DISK should only contain numbers and '%'."
    fi

    # remove temporary file
    echo "[-] Removing temporary file..."
    rm -f "${TMP_VALIDATE}"

    # give feedback to user whether the validation was succesful or not
    if [ "${VALIDATION_ERROR}" == '1' ]; then
        echo "[!] Validation errors have been found. Please fix them before trying again..."
        exit 1
    else
        echo "[i] No validation errors have been found..."
    fi
}

function serverbot_install_check {
    # check wheter serverbot.conf is already installed
    if [ -f /etc/serverbot/serverbot.conf ]; then
        # if true, ask the user whether a reinstall is intended
        while true
            do
                read -r -p '[?] serverbot is already installed, would you like to reinstall? (yes/no): ' REINSTALL
                [ "${REINSTALL}" = "yes" ] || [ "${REINSTALL}" = "no" ] && break
                error_type_yes_or_no
            done

        # exit if not intended
        if [ "${REINSTALL}" = "no" ]; then
            exit 0
        fi

        # reinstall when intended
        if [ "${REINSTALL}" = "yes" ]; then
            echo "[!] Serverbot will be reinstalled now..."
            serverbot_install
        fi
    else
        # if serverbot isn't currently installed, install it right away
        serverbot_install
    fi
}

function serverbot_install {
    # function requirements
    requirement_root
    gather_information_distro

    echo "[!] Serverbot will be installed now..."

    # update os
    echo "[+] Installing dependencies..."
    update_os

    # install dependencies for different package managers
    if [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        dnf install wget bc --assumeyes --quiet
    elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
        yum install wget bc --assumeyes --quiet
    elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        apt-get install aptitude bc curl --assume-yes --quiet
    elif [ "${PACKAGE_MANAGER}" == "pkg" ]; then
        pkg install bc wget
    #elif [ "${PACKAGE_MANAGER}" == "apk" ]; then
        #apk add # not sure about the rest
    fi

    # optionally configure method telegram
    while true
        do
            read -r -p '[?] Configure method Telegram? (yes/no): ' TELEGRAM_CONFIGURE
            [ "${TELEGRAM_CONFIGURE}" = "yes" ] || [ "${TELEGRAM_CONFIGURE}" = "no" ] && break
            error_type_yes_or_no
        done

    if [ "${TELEGRAM_CONFIGURE}" == 'yes' ]; then
        read -r -p '[?] Enter Telegram bot token: ' TELEGRAM_TOKEN
        read -r -p '[?] Enter Telegram chat ID:   ' TELEGRAM_CHAT_ID
    fi

    # add serverbot folder to /etc and add permissions
    echo "[+] Adding folders to system..."
    mkdir -m 755 /etc/serverbot
    # install latest version serverbot and add permissions
    echo "[+] Installing latest version of serverbot..."
    wget --quiet https://raw.githubusercontent.com/nozel-org/serverbot/${SERVERBOT_BRANCH}/serverbot.sh -O /usr/bin/serverbot
    chmod 755 /usr/bin/serverbot
    # add serverbot configuration file to /etc/serverbot and add permissions
    echo "[+] Adding configuration file to system..."
    wget --quiet https://raw.githubusercontent.com/nozel-org/serverbot/${SERVERBOT_BRANCH}/serverbot.conf -O /etc/serverbot/serverbot.conf
    chmod 644 /etc/serverbot/serverbot.conf

    # use current major version in /etc/serverbot/serverbot.conf
    echo "[+] Adding default config parameters to configuration file..."
    sed -i s%'major_version_here'%"$(echo "${SERVERBOT_VERSION}" | cut -c1)"%g /etc/serverbot/serverbot.conf
    sed -i s%'branch_here'%"$(echo "${SERVERBOT_BRANCH}")"%g /etc/serverbot/serverbot.conf

    # add telegram access token and chat id
    if [ "${TELEGRAM_CONFIGURE}" == 'yes' ]; then
        echo "[+] Adding telegram access token and chat ID to configuration file..."
        sed -i s%'telegram_token_here'%"${TELEGRAM_TOKEN}"%g /etc/serverbot/serverbot.conf
        sed -i s%'telegram_id_here'%"${TELEGRAM_CHAT_ID}"%g /etc/serverbot/serverbot.conf
    fi

    # creating or updating cronjobs
    echo "[+] Creating cronjobs..."
    /bin/bash /usr/bin/serverbot --cron
}

function compare_version {
    # source version information from github and remove dots
    source <(curl --silent https://raw.githubusercontent.com/nozel-org/serverbot/${SERVERBOT_BRANCH}/resources/version.txt)
    SERVERBOT_VERSION_CURRENT_NUMBER="$(echo "${SERVERBOT_VERSION}" | tr -d '.')"
    SERVERBOT_VERSION_RELEASE_NUMBER="$(echo "${VERSION_SERVERBOT}" | tr -d '.')"

    # check whether release version has a higher version number
    if [ "${SERVERBOT_VERSION_RELEASE_NUMBER}" -gt "${SERVERBOT_VERSION_CURRENT_NUMBER}" ]; then
        NEW_VERSION_AVAILABLE='1'
    fi
}

function serverbot_upgrade {
    # function requirements
    requirement_root
    compare_version

    # install new version if more recent version is available
    if [ "${NEW_VERSION_AVAILABLE}" == '1' ]; then
        echo "[i] New version of serverbot available, installing now..."
        echo "[i] Create temporary file for self-upgrade..."
        TMP_INSTALL="$(mktemp)"
        echo "[i] Download most recent version of serverbot..."
        wget --quiet https://raw.githubusercontent.com/nozel-org/serverbot/${SERVERBOT_BRANCH}/serverbot.sh -O "${TMP_INSTALL}"
        echo "[i] Set permissions on installation script..."
        chmod 700 "${TMP_INSTALL}"
        echo "[i] Executing installation script..."
        /bin/bash "${TMP_INSTALL}" --self-upgrade
    else
        echo "[i] No new version of serverbot available."
        exit 0
    fi
}

function serverbot_silent_upgrade {
    # function requirements
    requirement_root
    compare_version

    if [ "${NEW_VERSION_AVAILABLE}" == '1' ]; then
        # create temporary file for self-upgrade
        TMP_INSTALL="$(mktemp)"
        # download most recent version of serverbot
        wget --quiet https://raw.githubusercontent.com/nozel-org/serverbot/${SERVERBOT_BRANCH}/serverbot.sh -O "${TMP_INSTALL}"
        # set permissions on installation script
        chmod 700 "${TMP_INSTALL}"
        # executing installation script
        /bin/bash "${TMP_INSTALL}" --self-upgrade
    else
        # exit when no updates are available
        exit 0
    fi
}

function serverbot_self_upgrade {
    # function requirements
    requirement_root

    # download most recent version and add permissions
    wget --quiet https://raw.githubusercontent.com/nozel-org/serverbot/${SERVERBOT_BRANCH}/serverbot.sh -O /usr/bin/serverbot
    chmod 755 /usr/bin/serverbot
    echo "[i] Serverbot upgraded to version ${SERVERBOT_VERSION}..."

    # notify on telegram
    if [ "${SERVERBOT_UPGRADE_TELEGRAM}" == 'yes' ]; then
        # create message for telegram
        TELEGRAM_MESSAGE="$(echo -e "<b>Upgrade</b>: <code>${HOSTNAME}</code>\\nServerbot upgraded to version ${SERVERBOT_VERSION}.")"

        # call method_telegram
        method_telegram
    fi

    # exit when done
    exit 0
}

function serverbot_uninstall {
    # function requirements
    requirement_root

    # ask whether uninstall was intended
    while true
        do
            read -r -p '[?] Are you sure you want to uninstall serverbot? (yes/no): ' UNINSTALL
            [ "${UNINSTALL}" = "yes" ] || [ "${UNINSTALL}" = "no" ] && break
            error_type_yes_or_no
       done

        # exit if not intended
        if [ "${UNINSTALL}" = "no" ]; then
            exit 0
        fi

        # uninstall when intended
        if [ "${UNINSTALL}" = "yes" ]; then
            echo "[i] Serverbot will be uninstalled now..."
            echo "[-] Removing serverbot cronjobs from system..."
            rm -f /etc/cron.d/serverbot_*
            echo "[-] Removing serverbot.conf from system..."
            rm -rf /etc/serverbot
            echo "[-] Removing serverbot from system..."
            rm -f /usr/bin/serverbot
            exit 0
        fi
}

#############################################################################
# GENERAL FUNCTIONS
#############################################################################

function update_os {
    # function requirements
    requirement_root

    # update modern rhel based distributions
    if [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        dnf update --assumeyes --quiet
    # update older rhel based distributions
    elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
        yum update --assumeyes --quiet
    # update debian based distributions
    elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        apt-get update --quiet && apt-get upgrade --assume-yes --quiet
    # update alpine based distributions
    #elif [ "${PACKAGE_MANAGER}" == "apk" ]; then
        #apk # not sure about the rest
    fi
}

#############################################################################
# GATHER FUNCTIONS
#############################################################################

function gather_information_distro {
    # get os information from os-release
    source <(cat /etc/os-release | tr -d '.')

    # put distro name, id and version in variables
    DISTRO="${NAME}"
    DISTRO_ID="${ID}"
    DISTRO_VERSION="${VERSION_ID}"
}

function gather_information_server {
    # server information
    HOSTNAME="$(uname -n)"
    OPERATING_SYSTEM="$(uname -o)"
    KERNEL_NAME="$(uname -s)"
    KERNEL_VERSION="$(uname -r)"
    ARCHITECTURE="$(uname -m)"
    UPTIME="$(uptime -p)"
}

function gather_information_network {
    # internal IP address information
    INTERNAL_IP_ADDRESS="$(hostname -I)"

    # external IP address information
    EXTERNAL_IP_ADDRESS="$(curl --silent ipecho.net/plain)"
}

function gather_metrics_cpu {
    # function requirements
    requirement_root

    # cpu and load metrics
    CORE_AMOUNT="$(grep -c 'cpu cores' /proc/cpuinfo)"
    MAX_LOAD_SERVER="${CORE_AMOUNT}.00"
    COMPLETE_LOAD="$(< /proc/loadavg awk '{print $1" "$2" "$3}')"
    CURRENT_LOAD="$(< /proc/loadavg awk '{print $3}')"
    CURRENT_LOAD_PERCENTAGE="$(echo "(${CURRENT_LOAD}/${MAX_LOAD_SERVER})*100" | bc -l)"
    CURRENT_LOAD_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_LOAD_PERCENTAGE}" | tr -d '%'))"
}

function gather_metrics_memory {
    # gather software version of the free tool
    FREE_VERSION="$(free --version | awk '{ print $NF }' | tr -d '.')"

    # use old format when old version of free is used
    if [ "${FREE_VERSION}" -le "339" ]; then
        TOTAL_MEMORY="$(free -m | awk '/^Mem/ {print $2}')"
        FREE_MEMORY="$(free -m | awk '/^Mem/ {print $4}')"
        BUFFERS_MEMORY="$(free -m | awk '/^Mem/ {print $6}')"
        CACHED_MEMORY="$(free -m | awk '/^Mem/ {print $7}')"
        USED_MEMORY="$(echo "(${TOTAL_MEMORY}-${FREE_MEMORY}-${BUFFERS_MEMORY}-${CACHED_MEMORY})" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE="$(echo "(${USED_MEMORY}/${TOTAL_MEMORY})*100" | bc -l)"
        CURRENT_MEMORY_PERCENTAGE_ROUNDED="$(printf "%.0f\n" $(echo "${CURRENT_MEMORY_PERCENTAGE}" | tr -d '%'))"
    # use newer format when newer version of free is used
    elif [ "${FREE_VERSION}" -gt "339" ]; then
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
    # function requirements
    requirement_root

    # gather updates on modern rhel based distributions
    if [ "${PACKAGE_MANAGER}" == "dnf" ]; then
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(dnf check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Last\>//g')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    # gather updates on older rhel based distributions
    elif [ "${PACKAGE_MANAGER}" == "yum" ]; then
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(yum check-update | grep -v plugins | awk '(NR >=1) {print $1;}' | grep '^[[:alpha:]]' | sed 's/\<Loading\>//g')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    # gather updates on debian based distributions
    elif [ "${PACKAGE_MANAGER}" == "apt-get" ]; then
        # update repository
        apt-get --quiet update
        # list with available updates to variable AVAILABLE_UPDATES
        AVAILABLE_UPDATES="$(aptitude -F "%p" search '~U')"
        # outputs the character length of AVAILABLE_UPDATES in LENGTH_UPDATES
        LENGTH_UPDATES="${#AVAILABLE_UPDATES}"
    # gather updates on alpine based distributions
    #elif [ "${PACKAGE_MANAGER}" == "apk" ]; then
        #apk # not sure
    fi
}

function gather_eol {
    # function requirements
    gather_information_distro

    # modify basic distro information to upper case
    EOL_OS="$(echo ${DISTRO_ID}${DISTRO_VERSION} | tr '[:lower:]' '[:upper:]')"
    EOL_OS_NAME="EOL_${EOL_OS}"

    # source database with eol data
    source <(curl --silent https://raw.githubusercontent.com/nozel-org/serverbot/${SERVERBOT_BRANCH}/resources/eol.list | tr -d '.')

    # calculate epoch difference between current date and eol date
    EPOCH_EOL="$(date --date=$(echo "${!EOL_OS_NAME}") +%s)"
    EPOCH_CURRENT="$(date +%s)"
    EPOCH_DIFFERENCE="$(( ${EPOCH_EOL} - ${EPOCH_CURRENT} ))"
}

#############################################################################
# FEATURE FUNCTIONS
#############################################################################

function feature_overview_cli {
    # function requirements
    gather_information_server
    gather_information_network
    gather_information_distro
    gather_metrics_cpu
    gather_metrics_memory
    gather_metrics_disk

    # output server overview to shell
    echo "SYSTEM"
    echo "HOST:         ${HOSTNAME}"
    echo "OS:           ${OPERATING_SYSTEM}"
    echo "DISTRO:       ${DISTRO} ${DISTRO_VERSION}"
    echo "KERNEL:       ${KERNEL_NAME} ${KERNEL_VERSION}"
    echo "ARCHITECTURE: ${ARCHITECTURE}"
    echo "UPTIME:       ${UPTIME}"
    echo
    echo 'INTERNAL IP:'
    printf '%s\n'       ${INTERNAL_IP_ADDRESS}
    echo
    echo "EXTERNAL IP:"
    echo "${EXTERNAL_IP_ADDRESS}"
    echo
    echo 'HEALTH'
    echo "LOAD:         ${COMPLETE_LOAD}"
    echo "MEMORY:       ${USED_MEMORY}M / ${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)"
    echo "DISK:         ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)"

    # exit when done
    exit 0
}

function feature_overview_telegram {
    # function requirements
    gather_information_server
    gather_information_network
    gather_information_distro
    gather_metrics_cpu
    gather_metrics_memory
    gather_metrics_disk    

    # create message for telegram
    TELEGRAM_MESSAGE="$(echo -e "<b>Host</b>:                  <code>${HOSTNAME}</code>\\n<b>OS</b>:                      <code>${OPERATING_SYSTEM}</code>\\n<b>Distro</b>:               <code>${DISTRO} ${DISTRO_VERSION}</code>\\n<b>Kernel</b>:              <code>${KERNEL_NAME} ${KERNEL_VERSION}</code>\\n<b>Architecture</b>:  <code>${ARCHITECTURE}</code>\\n<b>Uptime</b>:             <code>${UPTIME}</code>\\n\\n<b>Internal IP</b>:\\n<code>${INTERNAL_IP_ADDRESS}</code>\\n\\n<b>External IP</b>:\\n<code>${EXTERNAL_IP_ADDRESS}</code>\\n\\n<b>Load</b>:                  <code>${COMPLETE_LOAD}</code>\\n<b>Memory</b>:           <code>${USED_MEMORY} M / ${TOTAL_MEMORY} M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)</code>\\n<b>Disk</b>:                   <code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>")"

    # call method_telegram
    method_telegram

    # exit when done
    exit 0
}

function feature_metrics_cli {
    # function requirements
    gather_information_server
    gather_metrics_cpu
    gather_metrics_memory
    gather_metrics_disk

    # output server metrics to shell
    echo "HOST:     ${HOSTNAME}"
    echo "UPTIME:   ${UPTIME}"
    echo "LOAD:     ${COMPLETE_LOAD}"
    echo "MEMORY:   ${USED_MEMORY}M / ${TOTAL_MEMORY}M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)"
    echo "DISK:     ${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)"

    # exit when done
    exit 0
}

function feature_metrics_telegram {
    # function requirements
    gather_information_server
    gather_metrics_cpu
    gather_metrics_memory
    gather_metrics_disk

    # create message for telegram
    TELEGRAM_MESSAGE="$(echo -e "<b>Host</b>:        <code>${HOSTNAME}</code>\\n<b>Uptime</b>:  <code>${UPTIME}</code>\\n\\n<b>Load</b>:         <code>${COMPLETE_LOAD}</code>\\n<b>Memory</b>:  <code>${USED_MEMORY} M / ${TOTAL_MEMORY} M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)</code>\\n<b>Disk</b>:          <code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>")"

    # call method_telegram
    method_telegram

    # exit when done
    exit 0
}

function feature_alert_cli {
    # function requirements
    gather_information_server
    gather_metrics_cpu
    gather_metrics_memory
    gather_metrics_disk
    gather_metrics_threshold

    # check whether the current server load exceeds the threshold and alert if true. Output server alert status to shell.
    if [ "${CURRENT_LOAD_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_LOAD_NUMBER}" ]; then
        echo -e "[!] SERVER LOAD:\\tA current server load of ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% exceeds the threshold of ${THRESHOLD_LOAD}."
    else
        echo -e "[i] SERVER LOAD:\\tA current server load of ${CURRENT_LOAD_PERCENTAGE_ROUNDED}% does not exceed the threshold of ${THRESHOLD_LOAD}."
    fi

    if [ "${CURRENT_MEMORY_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_MEMORY_NUMBER}" ]; then
        echo -e "[!] SERVER MEMORY:\\tA current memory usage of ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% exceeds the threshold of ${THRESHOLD_MEMORY}."
    else
        echo -e "[i] SERVER MEMORY:\\tA current memory usage of ${CURRENT_MEMORY_PERCENTAGE_ROUNDED}% does not exceed the threshold of ${THRESHOLD_MEMORY}."
    fi

    if [ "${CURRENT_DISK_PERCENTAGE}" -ge "${THRESHOLD_DISK_NUMBER}" ]; then
        echo -e "[!] DISK USAGE:\\t\\tA current disk usage of ${CURRENT_DISK_PERCENTAGE}% exceeds the threshold of ${THRESHOLD_DISK}."
    else
        echo -e "[i] DISK USAGE:\\t\\tA current disk usage of ${CURRENT_DISK_PERCENTAGE}% does not exceed the threshold of ${THRESHOLD_DISK}."
    fi

    # exit when done
    exit 0
}

function feature_alert_telegram {
    # function requirements
    gather_information_server
    gather_metrics_cpu
    gather_metrics_memory
    gather_metrics_disk
    gather_metrics_threshold

    # check whether the current server load exceeds the threshold and alert if true
    if [ "${CURRENT_LOAD_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_LOAD_NUMBER}" ]; then
        # create message for Telegram
        TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>ALERT: SERVER LOAD</b>\\n\\nThe server load (<code>${CURRENT_LOAD_PERCENTAGE_ROUNDED}%</code>) on <b>${HOSTNAME}</b> exceeds the threshold of <code>${THRESHOLD_LOAD}</code>\\n\\n<b>Load average:</b>\\n<code>${COMPLETE_LOAD}</code>")"

        # call method_telegram
        method_telegram
    fi

    # check whether the current server memory usage exceeds the threshold and alert if true
    if [ "${CURRENT_MEMORY_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_MEMORY_NUMBER}" ]; then
        # create message for Telegram
        TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>ALERT: SERVER MEMORY</b>\\n\\nMemory usage (<code>${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%</code>) on <b>${HOSTNAME}</b> exceeds the threshold of <code>${THRESHOLD_MEMORY}</code>\\n\\n<b>Memory usage:</b>\\n<code>$(free -m -h)</code>")"

        # call method_telegram
        method_telegram
    fi

    # check whether the current disk usaged exceeds the threshold and alert if true
    if [ "${CURRENT_DISK_PERCENTAGE}" -ge "${THRESHOLD_DISK_NUMBER}" ]; then
        # create message for Telegram
        TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>ALERT: FILE SYSTEM</b>\\n\\nDisk usage (<code>${CURRENT_DISK_PERCENTAGE}%</code>) on <b>${HOSTNAME}</b> exceeds the threshold of <code>${THRESHOLD_DISK}</code>\\n\\n<b>Filesystem info:</b>\\n<code>$(df -h)</code>")"

        # call method_telegram
        method_telegram
    fi

    # exit when done
    exit 0
}

function feature_updates_cli {
    # function requirements
    gather_updates

    # notify user when there are no updates
    if [ -z "${AVAILABLE_UPDATES}" ]; then
        echo "There are no updates available."
    else
        # notify user when there are updates available
        echo "The following updates are available:"
        echo
        echo "${AVAILABLE_UPDATES}"
    fi

    # exit when done
    exit 0
}

function feature_updates_telegram {
    # function requirements
    gather_information_server
    gather_updates

    # do nothing if there are no updates
    if [ -z "${AVAILABLE_UPDATES}" ]; then
        exit 0
    else
        # if update list length is less than 4000 characters, then sent update list
        if [ "${LENGTH_UPDATES}" -lt "4000" ]; then
            TELEGRAM_MESSAGE="$(echo -e "There are updates available on <b>${HOSTNAME}</b>:\n\n${AVAILABLE_UPDATES}")"
        fi

        # if update list length is greater than 4000 characters, don't sent update list
        if [ "${LENGTH_UPDATES}" -gt "4000" ]; then
            TELEGRAM_MESSAGE="There are updates available on <b>${HOSTNAME}</b>. Unfortunately, the list with updates is too large for Telegram. Please update your server as soon as possible."
        fi

        # call method_telegram
        method_telegram
    fi

    # exit when done
    exit 0
}

function feature_eol_cli {
    # function requirements
    gather_eol

    # first check on TBA entries, then check whether epoch difference is positive or negative
    if [ "${!EOL_OS_NAME}" == 'TBA' ]; then
        echo '[i] The EOL date of this operating system has not been added to the database yet. Try again later.'
    else
        if [[ "${EPOCH_DIFFERENCE}" -lt '0' ]]; then
            echo "[!] This operating system is end-of-life since ${!EOL_OS_NAME}."
        elif [[ "${EPOCH_DIFFERENCE}" -gt '0' ]]; then
            echo "[i] This operating system is supported $(( ${EPOCH_DIFFERENCE} / 86400 )) more days (until ${!EOL_OS_NAME})."
        fi
    fi
}

function feature_eol_telegram {
    # function requirements
    gather_information_server
    gather_eol

    # do nothing if eol date isn't in database
    if [ "${!EOL_OS_NAME}" == 'TBA' ]; then
        exit 0
    else
        # give eol notice around 6, 3 and 1 month before eol, and more frequently if its less than 1 month (depends on EOL_CRON parameter)
        if [[ "${EPOCH_DIFFERENCE}" -lt '0' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL NOTICE: ${HOSTNAME}</b>\\nThis operating system is end-of-life since ${!EOL_OS_NAME}.")"
        elif [[ "${EPOCH_DIFFERENCE}" -ge '14802000' ]] && [[ "${EPOCH_DIFFERENCE}" -lt '15552000' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL NOTICE: ${HOSTNAME}</b>\\nThis operating system will be end-of-life in $(( ${EPOCH_DIFFERENCE} / 86400 )) days (on ${!EOL_OS_NAME}).")"
        elif [[ "${EPOCH_DIFFERENCE}" -ge '7026000' ]] && [[ "${EPOCH_DIFFERENCE}" -lt '7776000' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL NOTICE: ${HOSTNAME}</b>\\nThis operating system will be end-of-life in $(( ${EPOCH_DIFFERENCE} / 86400 )) days (on ${!EOL_OS_NAME}).")"
        elif [[ "${EPOCH_DIFFERENCE}" -ge '1' ]] && [[ "${EPOCH_DIFFERENCE}" -lt '5184000' ]]; then
            TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>EOL NOTICE: ${HOSTNAME}</b>\\nThis operating system will be end-of-life in $(( ${EPOCH_DIFFERENCE} / 86400 )) days (on ${!EOL_OS_NAME}).")"
        fi
    fi

    # call method_telegram
    method_telegram

    # exit when done
    exit 0
}

function feature_outage {
    # return error when feature outage is unavailable
    if [ "${FEATURE_OUTAGE}" == 'disabled' ]; then
        error_not_available
    fi
}

#############################################################################
# METHOD FUNCTIONS
#############################################################################

function method_telegram {
    # return error when telegram is unavailable
    if [ "${METHOD_TELEGRAM}" == 'disabled' ]; then
        error_not_available
    fi

    # create payload for Telegram
    TELEGRAM_PAYLOAD="chat_id=${TELEGRAM_CHAT}&text=${TELEGRAM_MESSAGE}&parse_mode=HTML&disable_web_page_preview=true"

    # sent payload to Telegram API and exit
    curl --silent --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 -d "${TELEGRAM_PAYLOAD}" "${TELEGRAM_URL}" > /dev/null 2>&1 &
}

function method_email {
    # return error when email is unavailable
    if [ "${METHOD_EMAIL}" == 'disabled' ]; then
        error_not_available
    fi

    # planned for a later version
    error_not_yet_implemented
}

#############################################################################
# MAIN FUNCTION
#############################################################################

function serverbot_main {
    # check if os is supported
    requirement_os

    # check argument validity
    requirement_argument_validity

    # call relevant functions based on arguments
    if [ "${ARGUMENT_VERSION}" == '1' ]; then
        serverbot_version
    elif [ "${ARGUMENT_HELP}" == '1' ]; then
        serverbot_help
    elif [ "${ARGUMENT_CRON}" == '1' ]; then
        serverbot_cron
    elif [ "${ARGUMENT_VALIDATE}" == '1' ]; then
        serverbot_validate
    elif [ "${ARGUMENT_INSTALL}" == '1' ]; then
        serverbot_install_check
    elif [ "${ARGUMENT_UPGRADE}" == '1' ]; then
        serverbot_upgrade
    elif [ "${ARGUMENT_SILENT_UPGRADE}" == '1' ]; then
        serverbot_silent_upgrade
    elif [ "${ARGUMENT_SELF_UPGRADE}" == '1' ]; then
        serverbot_self_upgrade
    elif [ "${ARGUMENT_UNINSTALL}" == '1' ]; then
        serverbot_uninstall
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        feature_overview_cli
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
        feature_overview_telegram
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        error_not_yet_implemented
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        feature_metrics_cli
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
        feature_metrics_telegram
    elif [ "${ARGUMENT_METRICS}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        error_not_yet_implemented
    elif [ "${ARGUMENT_ALERT}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        feature_alert_cli
    elif [ "${ARGUMENT_ALERT}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
        feature_alert_telegram
    elif [ "${ARGUMENT_ALERT}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        error_not_yet_implemented
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        feature_updates_cli
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
        feature_updates_telegram
    elif [ "${ARGUMENT_UPDATES}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        error_not_yet_implemented
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        feature_eol_cli
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
        feature_eol_telegram
    elif [ "${ARGUMENT_EOL}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        error_not_yet_implemented
    elif [ "${ARGUMENT_NONE}" == '1' ]; then
        error_invalid_option
    fi
}

#############################################################################
# CALL MAIN FUNCTION
#############################################################################

serverbot_main
