#!/usr/bin/env bash

# Installs the NXM link broker script to a shared directory and sets it as executable.
# This script handles NXM links for Mod Organizer 2, allowing it to manage game mod downloads.
# Parameters:
#   - shared: The directory where the NXM link broker script will be installed.
#   - handlers: The directory containing the NXM link broker script.

log_info "installing nxm link broker in '$shared'"
cp "$handlers/modorganizer2-nxm-broker.sh" "$shared"
chmod +x "$shared/modorganizer2-nxm-broker.sh"

# Installs the NXM link handler desktop file into the user's application directory.
# This desktop file allows the system to recognize and handle NXM links.
# Parameters:
#   - HOME: The user's home directory, used to determine the application directory.
#   - handlers: The directory containing the NXM link handler desktop file.

app_dir="$HOME/.local/share/applications"
log_info "installing nxm link handler in '$app_dir/'"
mkdir -p "$app_dir"
cp "$handlers/modorganizer2-nxm-handler.desktop" "$app_dir/"

# Writes the game's app ID to a file in the installation directory.
# This file is used by Mod Organizer 2 to identify the game associated with the mods.
# Parameters:
#   - game_appid: The app ID of the game.
#   - install_dir: The directory where the app ID file will be created.

echo "$game_appid" > "$install_dir/appid.txt"

# Registers the NXM MIME type with the system using xdg-mime.
# This step ensures that NXM links are correctly handled by Mod Organizer 2.
# If xdg-mime is not available, a warning is logged, and the MIME type registration is skipped.

if [ -n "$(command -v xdg-mime)" ]; then
	xdg-mime default modorganizer2-nxm-handler.desktop x-scheme-handler/nxm
else
	log_warn "xdg-mime not found, cannot register mimetype"
fi
