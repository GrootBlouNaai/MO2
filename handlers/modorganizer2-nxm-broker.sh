#!/usr/bin/env bash

# Function to display error messages and exit
error_exit() {
    zenity --ok-label=Exit --error --text "$1"
    exit 1
}

# Check if the NXM link is provided
if [ -z "$1" ]; then
    error_exit "ERROR: please specify a NXM Link to download"
fi

nxm_link=$1
nexus_game_id=${nxm_link#nxm://}
nexus_game_id=${nexus_game_id%%/*}

instance_link="$HOME/.config/modorganizer2/instances/${nexus_game_id}"
instance_dir=$(readlink -f "$instance_link")

# Check if the instance directory exists
if [ ! -d "$instance_dir" ]; then
    [ -L "$instance_link" ] && rm "$instance_link"
    error_exit "Could not download file because there is no Mod Organizer 2 instance for '$nexus_game_id'"
fi

# Convert instance directory to Windows path format
instance_dir_windowspath="Z:$(sed 's/\//\\\\/g' <<<"$instance_dir")"

# Check if Mod Organizer 2 is running
pgrep -f "${instance_dir_windowspath}\\\\modorganizer2\\\\ModOrganizer.exe" > /dev/null
process_search_status=$?

game_appid=$(cat "$instance_dir/appid.txt")

# Start the download process
if [ "$process_search_status" -eq 0 ]; then
    echo "INFO: sending download '$nxm_link' to running Mod Organizer 2 instance"
    download_start_output=$(WINEESYNC=1 WINEFSYNC=1 protontricks-launch --appid "$game_appid" "$instance_dir/modorganizer2/nxmhandler.exe" "$nxm_link")
else
    echo "INFO: starting Mod Organizer 2 to download '$nxm_link'"
    download_start_output=$(steam -applaunch "$game_appid" "$nxm_link")
fi

download_start_status=$?

# Check if the download process started successfully
if [ "$download_start_status" -ne 0 ]; then
    error_exit "Failed to start download:\n\n$download_start_output"
fi
