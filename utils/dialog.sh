#!/usr/bin/env bash

dialogtype=$1; shift

if ! command -v zenity &> /dev/null; then
    echo "ERROR: no interface available, make sure zenity is installed on your system" >&2
    exit 1
fi

errorbox() {
    zenity --ok-label=Exit --error --text "$1"
}

infobox() {
    zenity --ok-label=Continue --info --text "$1"
}

warnbox() {
    zenity --ok-label=Continue --warning --text "$1"
}

question() {
    zenity --question --text="$1" >/dev/null
    echo $?
}

dangerquestion() {
    zenity --extra-button=No --ok-label=Yes --warning --text="$1" >/dev/null
    echo $?
}

directorypicker() {
    local message=$1
    local default_directory=$2
    local selection_entry="$default_directory"

    while true; do
        local raw_entry=$(zenity --entry --entry-text="$selection_entry" --extra-button="Browse" --text "$message")
        local confirm=$?
        eval selection_entry="$raw_entry"

        case $confirm in
            0)
                if [ ! -e "$selection_entry" ]; then
                    if question "Directory '$selection_entry' does not exist. Would you like to create it?"; then
                        mkdir -p "$selection_entry"
                        echo "$(realpath "$selection_entry")"
                        return 0
                    fi
                elif [ -n "$(ls -A "$selection_entry")" ]; then
                    if dangerquestion "Directory '$selection_entry' is not empty. Would you like to continue anyway?"; then
                        echo "$(realpath "$selection_entry")"
                        return 0
                    fi
                else
                    echo "$(realpath "$selection_entry")"
                    return 0
                fi
                ;;
            1)
                if [ "$selection_entry" == "Browse" ]; then
                    selection_entry=$(zenity --file-selection --directory)
                else
                    return 1
                fi
                ;;
        esac
    done
}

textentry() {
    local message=$1
    local default_value=$2
    local entry_value=$(zenity --entry --entry-text="$default_value" --text "$message")
    local confirm=$?

    if [ $confirm -eq 0 ]; then
        echo "$entry_value"
    fi

    return $confirm
}

radio() {
    local height=$1
    local title=$2
    shift 2

    local rows=()
    while [ $# -gt 0 ]; do
        rows+=('' "$1" "$2")
        shift 2
    done

    local selected_option=$(
        zenity --height="$height" --list --radiolist \
        --text="$title" \
        --hide-header \
        --column="checkbox" --column="option_value" --column="option_text" \
        --hide-column=2 \
        "${rows[@]}"
    )

    if [ -z "$selected_option" ]; then
        return 1
    fi

    echo "$selected_option"
    return 0
}

loading() {
    tee /dev/tty <&0 | zenity --progress --auto-close --pulsate --no-cancel --text "$1"
}

$dialogtype "$@"
exit $?
