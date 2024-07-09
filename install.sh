#!/usr/bin/env bash

set -eu
set -o pipefail

SCRIPT_ROOT=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
UTILS="$SCRIPT_ROOT/utils"
DIALOG="$UTILS/dialog.sh"
GAMESINFO="$SCRIPT_ROOT/gamesinfo"
HANDLERS="$SCRIPT_ROOT/handlers"
LAUNCHERS="$SCRIPT_ROOT/launchers"
REDIRECTOR="$SCRIPT_ROOT/steam-redirector"
STEP="$SCRIPT_ROOT/step"
WORKAROUNDS="$SCRIPT_ROOT/workarounds"
DOWNLOADS_CACHE="/tmp/mo2-linux-installer-downloads-cache"
SHARED="$HOME/.local/share/modorganizer2"

CACHE_ENABLED="${CACHE:-1}"
STARTED_DOWNLOAD_STEP=0
EXPECT_EXIT=0

mkdir -p "$DOWNLOADS_CACHE"
mkdir -p "$SHARED"

handle_error() {
    if [ "$EXPECT_EXIT" != "1" ]; then
        if [ "$STARTED_DOWNLOAD_STEP" == "1" ]; then
            purge_downloads_cache
        fi
        "$DIALOG" errorbox "Operation canceled. Check the terminal for details"
    fi
}

log_info() {
    echo "INFO:" "$@" >&2
}

log_warn() {
    echo "WARN:" "$@" >&2
}

log_error() {
    echo "ERROR:" "$@" >&2
}

trap handle_error EXIT

if [ "$UID" == "0" ]; then
    log_error "Attempted to run as root"
    log_error "Please follow the install instructions provided at https://github.com/rockerbacon/modorganizer2-linux-installer"
    exit 1
fi

EXPECT_EXIT=1

source "$STEP/check_dependencies.sh"

SELECTED_GAME=$(source "$STEP/select_game.sh")
log_info "selected game '$SELECTED_GAME'"

source "$STEP/load_gameinfo.sh"
source "$STEP/clean_game_prefix.sh"

INSTALL_DIR=$(source "$STEP/select_install_dir.sh")
log_info "selected install directory '$INSTALL_DIR'"

EXPECT_EXIT=0

source "$STEP/download_external_resources.sh"
source "$STEP/install_external_resources.sh"
source "$STEP/install_nxm_handler.sh"
source "$STEP/configure_steam_wineprefix.sh"
source "$STEP/install_steam_redirector.sh"
source "$STEP/register_installation.sh"

source "$STEP/apply_workarounds.sh"

log_info "installation completed successfully"
EXPECT_EXIT=1
"$DIALOG" infobox "Installation successful!\n\Launch the game on Steam to use Mod Organizer 2"
