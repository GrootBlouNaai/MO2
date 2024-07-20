#!/usr/bin/env bash

# Load the game-specific information script based on the selected game.
# This script is expected to be located in the $gamesinfo directory with a filename corresponding to the selected game.
load_gameinfo="$gamesinfo/$selected_game.sh"

# Check if the game-specific information script exists.
# If it does not exist, log an error and display an error dialog to the user, then exit the script with a status code of 1.
if [ ! -f "$load_gameinfo" ]; then
	log_error "no gameinfo for '$selected_game'"
	"$dialog" errorbox \
		"Could not find information on '$selected_game'"
	exit 1
fi

# Source the game-specific information script to load variables and functions related to the selected game.
source "$load_gameinfo"

# Validate that the game_appid variable is not empty.
# If it is empty, log an error and exit the script with a status code of 1.
if [ -z "$game_appid" ]; then
	log_error "empty game_appid"
	exit 1
# Validate that the game_steam_subdirectory variable is not empty.
# If it is empty, log an error and exit the script with a status code of 1.
elif [ -z "$game_steam_subdirectory" ]; then
	log_error "empty steam_subdirectory"
	exit 1
fi

# Use a utility script to find the Steam library that contains the game executable.
# This script searches through the Steam libraries to locate the directory containing the specified game executable.
steam_library=$("$utils/find-library-for-file.sh" "$game_steam_subdirectory/$game_executable")

# Check if the Steam library directory does not exist.
# If it does not exist, log an error, display an error dialog to the user, and exit the script with a status code of 1.
if [ ! -d "$steam_library" ]; then
	log_error "could not find any Steam library containing a game with appid '$game_appid'. If you know exactly where the library is, you can specify it using the environment variable STEAM_LIBRARY"
	"$dialog" errorbox \
		"Could not find '$game_steam_subdirectory' in any of your Steam libraries\nMake sure the game is installed and that you've run it at least once"
	exit 1
fi

# Define the path to the game installation directory within the Steam library.
# This path is constructed using the Steam library path and the game's subdirectory name.
game_installation="$steam_library/steamapps/common/$game_steam_subdirectory"

# Defer loading the game_prefix and game_compatdata variables to the clean_game_prefix.sh script.
# These variables are initialized as empty strings here but will be populated by another script later.
game_prefix=''
game_compatdata=''
