#!/usr/bin/env bash

# Creates the directory structure for Mod Organizer 2 instances if it doesn't already exist.
# This directory is used by Mod Organizer 2 to manage different game instances.
# Parameters:
#   - HOME: The user's home directory, used to determine the path to the Mod Organizer 2 configuration directory.

mkdir -p "$HOME/.config/modorganizer2/instances"

# Removes any existing symbolic link for the game instance in the Mod Organizer 2 instances directory.
# This ensures that the link points to the correct installation directory.
# Parameters:
#   - HOME: The user's home directory, used to determine the path to the Mod Organizer 2 configuration directory.
#   - game_nexusid: The Nexus Mods ID of the game, used to name the symbolic link.

rm -f "$HOME/.config/modorganizer2/instances/$game_nexusid"

# Creates a symbolic link in the Mod Organizer 2 instances directory pointing to the game's installation directory.
# This link allows Mod Organizer 2 to manage the game's mods and configurations.
# Parameters:
#   - install_dir: The directory where the game is installed.
#   - HOME: The user's home directory, used to determine the path to the Mod Organizer 2 configuration directory.
#   - game_nexusid: The Nexus Mods ID of the game, used to name the symbolic link.

ln -s "$install_dir" "$HOME/.config/modorganizer2/instances/$game_nexusid"
