#!/usr/bin/env bash

# Checks if there are any Protontricks specified for the game.
# If so, it applies them to the game's Proton prefix.
# Parameters:
#   - game_protontricks: An array of Protontricks to be applied.
#   - game_appid: The app ID of the game, used to identify the game's Proton prefix.
#   - utils: The directory containing utility scripts, such as protontricks.sh.
#   - dialog: The path to a dialog utility used for displaying messages to the user.

if [ -n "${game_protontricks[*]}" ]; then
	log_info "applying protontricks ${game_protontricks[@]}"

	# Applies the specified Protontricks to the game's Proton prefix.
	# Displays a loading dialog while the Protontricks are being applied.
	# If the Protontricks application fails, an error dialog is shown, and the script exits with a non-zero status.

	"$utils/protontricks.sh" apply "$game_appid" "${game_protontricks[@]}" \
		| "$dialog" loading "Configuring game prefix\nThis may take a while"

	if [ "$?" != "0" ]; then
		"$dialog" errorbox \
			"Error while installing winetricks, check the terminal for more details"
		exit 1
	fi
fi
