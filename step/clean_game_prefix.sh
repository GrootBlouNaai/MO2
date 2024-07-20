#!/usr/bin/env bash

# Define the text for confirming the cleaning of the current game prefix.
# This text informs the user about the recommendation to clean the game prefix before installation.
confirm_cleaning_text=$( \
cat << EOF
It is highly recommended to clean your current game prefix before starting the installation process.

Would you like to archive your current game prefix and create a new one?
EOF
)

# Define the text for creating a clean prefix.
# This text provides step-by-step instructions for the user to create a new clean prefix using Steam and Proton.
create_clean_prefix_text=$( \
cat << EOF
Now you need to create a clean prefix:

1. On Steam: right click the game > Properties > Compatibility
2. Check the option "Force the use of a specific Steam Play compatibility tool"
3. Select the Proton version you would like to use
	* Proton 9.0 is the currently supported and recommended version
4. Launch the game and wait for Steam to finish its setup
5. Close the game. It must remain stopped through the entire install process
EOF
)

# Define a function to archive the existing game prefix.
# This function moves the existing game prefix to an archive directory with a timestamp to avoid overwriting.
function archive_existing_prefix() {
	game_compatdata_archive="$game_compatdata.$(date +%Y%m%d%H%M%S)"
	if [ -e "$game_compatdata_archive" ]; then
		log_error "cannot archive prefix, '$game_compatdata_archive' already exists"
		return 1
	fi
	log_info "moving '$game_compatdata' to '$game_compatdata_archive'"
	mv "$game_compatdata" "$game_compatdata_archive"
	echo "[$(date --iso-8601=minutes)] '$selected_game' prefix archived in '$game_compatdata_archive'" >> "$shared/archived_prefixes.log"
}

# Define a function to restore user data from the archived prefix.
# This function moves user data from the archived prefix to the new prefix.
function restore_archived_userdata() {
	local src="$game_compatdata_archive/pfx/drive_c/users"
	local dst="$game_prefix/drive_c/users"

	log_info "archiving '$dst' to '$dst.bak'"
	mv "$dst" "$dst.bak"

	log_info "moving '$src' to '$dst'"
	mv "$src" "$dst"
}

# Define a function to create a new prefix.
# This function displays a dialog to the user to confirm the creation of a new prefix.
function create_new_prefix() {
	confirmation=$( \
		"$dialog" \
			radio \
			425 "$create_clean_prefix_text" \
			"1" "Cancel the installation" \
			"0" "All done. Let's continue" \
	)

	echo "$confirmation"
}

# Define a function to load the locations of the game prefix and compatibility data.
# This function uses a utility script to find the prefix and compatibility data directories.
function load_prefix_locations() {
	game_prefix=$("$utils/protontricks.sh" get-prefix "$game_appid")
	if [ -n "$game_prefix" ]; then
		game_compatdata=$(dirname "$game_prefix")
	fi
}

# Initialize the game compatibility data archive variable.
game_compatdata_archive=''

# Load the prefix locations.
load_prefix_locations

# If a game prefix exists, ask the user if they want to clean it.
if [ -n "$game_prefix" ]; then
	confirm_cleaning=$("$dialog" question "$confirm_cleaning_text")
	if [ "$confirm_cleaning" == "0" ]; then
		archive_existing_prefix
	else
		log_info "proceeding with existing prefix"
	fi
fi

# Ask the user to confirm the creation of a new prefix.
confirm_new_prefix=$(create_new_prefix)
if [ "$confirm_new_prefix" != "0" ]; then
	log_error "installation cancelled by the user"
	exit 1
fi
log_info "user confirmed prefix setup"

# Reload the prefix locations to ensure the latest data is used.
load_prefix_locations

# If no prefix is found, log an error and display an error dialog to the user.
if [ -z "$game_prefix" ]; then
	log_error "no prefix found"
	"$dialog" \
		errorbox \
		"A prefix for the selected game could not be found.\nMake sure you have followed the instructions on creating a clean prefix.\nCheck the terminal output for more details."
	exit 1
fi

# If an archived prefix exists, restore the user data from it.
if [ -n "$game_compatdata_archive" ]; then
	restore_archived_userdata

	# Define the text for informing the user about the archived prefix.
	archive_information_text=$( \
cat <<EOF
Your old prefix has been archived at:
$game_compatdata_archive

Your personal data has been automatically moved to your new prefix.
You're free to delete the old archive after confirming your
mod lists and save files are intact.

A list of all archived prefixes is available at:
$shared/archived_prefixes.log
EOF
)

	# Display the archive information to the user.
	"$dialog" infobox "$archive_information_text"
fi
