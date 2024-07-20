#!/usr/bin/env bash

# Ensures that the script exits with an error if any command fails and treats unset variables as an error.
set -eu
set -o pipefail

# Sets the root directory of the script to the directory containing the script.
SCRIPT_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Defines paths to various directories and utilities used throughout the script.
UTILS="$SCRIPT_ROOT/utils"
DIALOG="$UTILS/dialog.sh"
GAMESINFO="$SCRIPT_ROOT/gamesinfo"
HANDLERS="$SCRIPT_ROOT/handlers"
LAUNCHERS="$SCRIPT_ROOT/launchers"
REDIRECTOR="$SCRIPT_ROOT/steam-redirector"
STEP="$SCRIPT_ROOT/step"
WORKAROUNDS="$SCRIPT_ROOT/workarounds"

# Defines directories for caching downloads and shared resources.
DOWNLOADS_CACHE="/tmp/mo2-linux-installer-downloads-cache"
SHARED="$HOME/.local/share/modorganizer2"

# Defines whether caching is enabled and initializes variables for tracking the state of the script.
CACHE_ENABLED="${CACHE:-1}"
STARTED_DOWNLOAD_STEP=0
EXPECT_EXIT=0

# Creates directories for caching downloads and shared resources if they do not already exist.
mkdir -p "$DOWNLOADS_CACHE"
mkdir -p "$SHARED"

# Defines a function to handle errors, ensuring that any started download steps are cleaned up if the script exits unexpectedly.
handle_error() {
    if [ "$EXPECT_EXIT" != "1" ]; then
        if [ "$STARTED_DOWNLOAD_STEP" == "1" ]; then
            purge_downloads_cache
        fi
        "$DIALOG" errorbox "Operation canceled. Check the terminal for details"
    fi
}

# Defines logging functions for info, warning, and error messages.
log_info() {
    echo "INFO:" "$@" >&2
}

log_warn() {
    echo "WARN:" "$@" >&2
}

log_error() {
    echo "ERROR:" "$@" >&2
}

# Sets up a trap to call the handle_error function on script exit.
trap handle_error EXIT

# Checks if the script is being run as root and exits with an error if it is, as running as root is not recommended.
if [ "$UID" == "0" ]; then
    log_error "Attempted to run as root"
    log_error "Please follow the install instructions provided at https://github.com/rockerbacon/modorganizer2-linux-installer"
    exit 1
fi

# Sets the EXPECT_EXIT flag to 1 to indicate that the script is expected to exit.
EXPECT_EXIT=1

# Checks for dependencies required by the script.
source "$STEP/check_dependencies.sh"

# Prompts the user to select a game for which to install Mod Organizer 2.
SELECTED_GAME=$(source "$STEP/select_game.sh")
log_info "selected game '$SELECTED_GAME'"

# Loads game-specific information and cleans the game prefix.
source "$STEP/load_gameinfo.sh"
source "$STEP/clean_game_prefix.sh"

# Prompts the user to select an installation directory for Mod Organizer 2.
INSTALL_DIR=$(source "$STEP/select_install_dir.sh")
log_info "selected install directory '$INSTALL_DIR'"

# Resets the EXPECT_EXIT flag to 0 to indicate that the script is no longer expected to exit.
EXPECT_EXIT=0

# Downloads external resources required for the installation.
source "$STEP/download_external_resources.sh"

# Installs the downloaded external resources.
source "$STEP/install_external_resources.sh"

# Installs the NXM handler for managing mod downloads.
source "$STEP/install_nxm_handler.sh"

# Configures the Steam Wine prefix for compatibility with Mod Organizer 2.
source "$STEP/configure_steam_wineprefix.sh"

# Installs the Steam redirector to manage game launches through Mod Organizer 2.
source "$STEP/install_steam_redirector.sh"

# Registers the installation with Mod Organizer 2.
source "$STEP/register_installation.sh"

# Applies any necessary workarounds for compatibility issues.
source "$STEP/apply_workarounds.sh"

# Logs a message indicating that the installation was successful.
log_info "installation completed successfully"

# Sets the EXPECT_EXIT flag to 1 to indicate that the script is expected to exit.
EXPECT_EXIT=1

# Displays a message to the user indicating that the installation was successful.
"$DIALOG" infobox "Installation successful!\n\Launch the game on Steam to use Mod Organizer 2"
