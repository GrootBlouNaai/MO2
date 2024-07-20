#!/usr/bin/env bash

# Creates the directory structure for the game installation within Mod Organizer 2.
# Parameters:
#   - game_installation: The directory where the game is installed.

mkdir -p "$game_installation/modorganizer2"

# Converts the installation directory path to a Windows-style path.
# This is necessary for compatibility with Mod Organizer 2, which runs under Proton/Wine.
# Parameters:
#   - install_dir: The installation directory path.

installdir_windowspath="Z:$(tr '/' '\\' <<< "$install_dir")"
mo2_executable_windowspath="$installdir_windowspath\\modorganizer2\\ModOrganizer.exe"

# Defines the path for the configuration file that will store the Mod Organizer 2 executable path.
# Parameters:
#   - game_installation: The directory where the game is installed.

mo2_executable_path_config="$game_installation/modorganizer2/instance_path.txt"

# Writes the Mod Organizer 2 executable path to the configuration file.
# This ensures that Mod Organizer 2 can locate its executable when running under Proton/Wine.
# Parameters:
#   - mo2_executable_windowspath: The Windows-style path to the Mod Organizer 2 executable.
#   - mo2_executable_path_config: The path to the configuration file.

log_info "configuring mo2 executable path '$mo2_executable_windowspath' in '$mo2_executable_path_config'"
echo "$mo2_executable_windowspath" > "$mo2_executable_path_config"

# Defines the path for the original game executable backup.
# This is used to restore the original executable if needed.
# Parameters:
#   - game_installation: The directory where the game is installed.
#   - game_executable: The name of the game executable.

original_game_executable="$game_installation/_$game_executable"

# Defines the full path to the game executable.
# Parameters:
#   - game_installation: The directory where the game is installed.
#   - game_executable: The name of the game executable.

full_game_executable_path="$game_installation/$game_executable"

# Backs up the original game executable if it hasn't been backed up already.
# This ensures that the original executable can be restored if needed.
# Parameters:
#   - full_game_executable_path: The full path to the game executable.
#   - original_game_executable: The path to the backup location for the game executable.

if [ ! -f "$original_game_executable" ]; then
	log_info "backing up original executable '$full_game_executable_path' in '$original_game_executable'"
	mv "$full_game_executable_path" "$original_game_executable"
fi

# Sets up a redirector executable in place of the original game executable.
# This redirector allows Mod Organizer 2 to manage the game's execution.
# Parameters:
#   - full_game_executable_path: The full path to the game executable.
#   - redirector: The directory containing the redirector executable.

log_info "setting up redirector in '$full_game_executable_path'"
cp -f "$redirector/main.exe" "$full_game_executable_path"
