#!/bin/bash

#############################################################################
# Version 1.0.0-UNSTABLE (13-12-2019)
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

# remindbot version
REMINDBOT_VERSION='1.0.0'

# check whether remindbot.conf is available and source it
if [ -f /etc/remindbot/remindbot.conf ]; then
    source /etc/remindbot.conf
    # check whether method telegram has been configured
    if [ "${TELEGRAM_TOKEN}" == 'telegram_token_here' ]; then
        METHOD_TELEGRAM='disabled'
    fi
else
    # otherwise exit
    echo 'remindbot: cannot find /etc/remindbot/remindbot.conf'
    echo "Install the configuration file to use remindbot."
    exit 1
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

        --retrieve|retrieve)
            ARGUMENT_RETRIEVE='1'
            ARGUMENT_OPTION='1'

        # features
        --overview|overview)
            ARGUMENT_OVERVIEW='1'
            ARGUMENT_FEATURE='1'
            shift
            ;;

        --remind|remind)
            ARGUMENT_REMIND='1'
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
    echo 'remindbot: invalid option'
    echo "Use 'remindbot --help' for a list of valid arguments."
    exit 1
}

function error_wrong_amount_of_arguments {
    echo 'remindbot: wrong amount of arguments'
    echo "Use 'remindbot --help' for a list of valid arguments."
    exit 1
}

function error_not_yet_implemented {
    echo 'remindbot: this feature has not been implemented yet.'
    exit 1
}

function error_os_not_supported {
    echo 'remindbot: operating system is not supported.'
    exit 1
}

function error_not_available {
    echo 'remindbot: option or method is not available without the remindbot configuration file.'
    exit 1
}

function error_no_feature_and_method {
    echo 'remindbot: feature requires a method and vice versa'
    echo "Use 'remindbot --help' for a list of valid arguments."
    exit 1
}

function error_options_cannot_be_combined {
    echo 'remindbot: options cannot be used with features or methods'
    echo "Use 'remindbot --help' for a list of valid arguments."
    exit 1
}

function error_no_root_privileges {
    echo 'remindbot: you need to be root to perform this command'
    echo "use 'sudo remindbot', 'sudo -s' or run remindbot as root user."
    exit 1
}

function error_no_internet_connection {
    echo 'remindbot: access to the internet is required.'
    exit 1
}

function error_type_yes_or_no {
    echo "remindbot: type yes or no and press enter to continue."
}

function error_method_telegram_disabled {
    echo "remindbot: method telegram is unavailable without correct configuration in remindbot configuration file."
    exit 1
}

function error_method_email_disabled {
    echo "remindbot: method email is unavailable without correct configuration in remindbot configuration file."
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

function remindbot_version {
    echo "Remindbot ${REMINDBOT_VERSION}"
    echo "Copyright (C) 2016-2019 Nozel."
    echo "License CC Attribution-NonCommercial-ShareAlike 4.0 Int."
    echo
    echo "Written by Sebas Veeke"
}

function remindbot_help {
    echo "Usage:"
    echo " remindbot [feature]... [method]..."
    echo " remindbot [option]..."
    echo
    echo "Features:"
    echo " --overview        Show reminders overview"
    echo " --remind          Show reminders"
    echo
    echo "Methods:"
    echo " --cli             Output [feature] to command line"
    echo " --telegram        Output [feature] to Telegram bot"
    #echo "--email           Output [feature] to e-mail"
    echo
    echo "Options:"
    echo " --retrieve        Retrieve reminders from link"
    echo " --cron            Effectuate cron changes from remindbot config"
    echo " --validate        Check validity of remindbot.conf"
    echo " --help            Display this help and exit"
    echo " --version         Display version information and exit"
}

function remindbot_cron {
    # function requirements
    requirement_root
    remindbot_validate

    # return error when config file isn't installed on the system
    if [ "${REMINDBOT_CONFIG}" == 'disabled' ]; then
        error_not_available
    fi

    echo '*** UPDATING CRONJOBS ***'
    # remove cronjobs so automated tasks can also be deactivated
    echo '[-] Removing old remindbot cronjobs...'
    rm -f /etc/cron.d/remindbot_*
    # update cronjobs automated tasks
    if [ "${OVERVIEW_TELEGRAM}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated reminder overviews on Telegram...'
        echo -e "# This cronjob activates a automated reminder overview on Telegram on the chosen schedule\n${OVERVIEW_CRON} root /usr/bin/remindbot --overview --telegram" > /etc/cron.d/remindbot_overview_telegram
    fi
    if [ "${REMINDER_TELEGRAM}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated reminders on Telegram...'
        echo -e "# This cronjob activates automated reminders on Telegram on the chosen schedule\n${REMINDER_CRON}_CRON} root /usr/bin/remindbot --metrics --telegram" > /etc/cron.d/remindbot_remind_telegram
    fi
    if [ "${RETRIEVE_REMINDERS}" == 'yes' ]; then
        echo '[+] Updating cronjob for automated retrieval of reminders...'
        echo -e "# This cronjob activates automated retrieval of reminders on the chosen schedule\n${RETRIEVE_CRON}_CRON} root /usr/bin/remindbot --retrieve" > /etc/cron.d/remindbot_retrieve_reminders
    fi

    # give user feedback when all automated tasks are disabled
    if [ "${OVERVIEW_TELEGRAM}" != 'yes' ] && \
    [ "${REMINDER_TELEGRAM}" != 'yes' ] && \
    [ "${RETRIEVE_REMINDERS}" != 'yes' ] then
        echo '[i] All automated tasks are disabled, no cronjobs to update...'
        exit 0
    fi

    # restart cron to really effectuate the new cronjobs
    echo '[+] Restart the cron service to effectuate the changes...'
    exit 0
}

function remindbot_retrieve {
    wget --quiet ${RETRIEVE_URL} -O /etc/remindbot/reminders.list
}

#############################################################################
# FEATURE FUNCTIONS
#############################################################################

    # source database with reminders data
    source <(curl --silent https://raw.githubusercontent.com/nozel-org/remindbot/${REMINDBOT_BRANCH}/resources/eol.list | tr -d '.')

    # calculate epoch difference between current date and eol date
    EPOCH_EOL="$(date --date=$(echo "${!EOL_OS_NAME}") +%s)"
    EPOCH_CURRENT="$(date +%s)"
    EPOCH_DIFFERENCE="$(( ${EPOCH_EOL} - ${EPOCH_CURRENT} ))"


function feature_overview_cli {
    # retreive 
    # output server overview to shell
    echo "SYSTEM"


    # exit when done
    exit 0
}

function feature_overview_telegram {
    # create message for telegram
    TELEGRAM_MESSAGE="$(echo -e "<b>Host</b>:                  <code>${HOSTNAME}</code>\\n<b>OS</b>:                      <code>${OPERATING_SYSTEM}</code>\\n<b>Distro</b>:               <code>${DISTRO} ${DISTRO_VERSION}</code>\\n<b>Kernel</b>:              <code>${KERNEL_NAME} ${KERNEL_VERSION}</code>\\n<b>Architecture</b>:  <code>${ARCHITECTURE}</code>\\n<b>Uptime</b>:             <code>${UPTIME}</code>\\n\\n<b>Internal IP</b>:\\n<code>${INTERNAL_IP_ADDRESS}</code>\\n\\n<b>External IP</b>:\\n<code>${EXTERNAL_IP_ADDRESS}</code>\\n\\n<b>Load</b>:                  <code>${COMPLETE_LOAD}</code>\\n<b>Memory</b>:           <code>${USED_MEMORY} M / ${TOTAL_MEMORY} M (${CURRENT_MEMORY_PERCENTAGE_ROUNDED}%)</code>\\n<b>Disk</b>:                   <code>${CURRENT_DISK_USAGE} / ${TOTAL_DISK_SIZE} (${CURRENT_DISK_PERCENTAGE}%)</code>")"

    # call method_telegram
    method_telegram

    # exit when done
    exit 0
}

function feature_remind_cli {
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

function feature_remind_telegram {
    # check whether the current server load exceeds the threshold and alert if true
    if [ "${CURRENT_LOAD_PERCENTAGE_ROUNDED}" -ge "${THRESHOLD_LOAD_NUMBER}" ]; then
        # create message for Telegram
        TELEGRAM_MESSAGE="$(echo -e "\xE2\x9A\xA0 <b>ALERT: SERVER LOAD</b>\\n\\nThe server load (<code>${CURRENT_LOAD_PERCENTAGE_ROUNDED}%</code>) on <b>${HOSTNAME}</b> exceeds the threshold of <code>${THRESHOLD_LOAD}</code>\\n\\n<b>Load average:</b>\\n<code>${COMPLETE_LOAD}</code>")"

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

function remindbot_main {
    # check if os is supported
    requirement_os

    # check argument validity
    requirement_argument_validity

    # call relevant functions based on arguments
    if [ "${ARGUMENT_VERSION}" == '1' ]; then
        remindbot_version
    elif [ "${ARGUMENT_HELP}" == '1' ]; then
        remindbot_help
    elif [ "${ARGUMENT_CRON}" == '1' ]; then
        remindbot_cron
    elif [ "${ARGUMENT_RETRIEVE}" == '1' ]; then
        remindbot_retrieve
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        feature_overview_cli
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
        feature_overview_telegram
    elif [ "${ARGUMENT_OVERVIEW}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        error_not_yet_implemented
    elif [ "${ARGUMENT_REMIND}" == '1' ] && [ "${ARGUMENT_CLI}" == '1' ]; then
        feature_remind_cli
    elif [ "${ARGUMENT_REMIND}" == '1' ] && [ "${ARGUMENT_TELEGRAM}" == '1' ]; then
        feature_remind_telegram
    elif [ "${ARGUMENT_REMIND}" == '1' ] && [ "${ARGUMENT_EMAIL}" == '1' ]; then
        error_not_yet_implemented
    elif [ "${ARGUMENT_NONE}" == '1' ]; then
        error_invalid_option
    fi
}

#############################################################################
# CALL MAIN FUNCTION
#############################################################################

remindbot_main
