#!/usr/bin/env bash

# Define the paths to the download and extract scripts located in the utils directory.
download="$utils/download.sh"
extract="$utils/extract.sh"

# Define the URLs for the JDK, Mod Organizer 2 (MO2), and Winetricks.
jdk_url='https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u312-b07/OpenJDK8U-jre_x64_windows_hotspot_8u312b07.zip'
mo2_url='https://github.com/ModOrganizer2/modorganizer/releases/download/v2.5.0/Mod.Organizer-2.5.0.7z'
winetricks_url='https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'

# Define the paths where the downloaded JDK, MO2, and Winetricks files will be stored.
# The paths are derived from the URLs and the downloads_cache directory.
downloaded_jdk="$downloads_cache/${jdk_url##*/}"
extracted_jdk="${downloaded_jdk%.*}"
downloaded_winetricks="$downloads_cache/winetricks"
executable_winetricks="$shared/winetricks"

downloaded_mo2="$downloads_cache/${mo2_url##*/}"
extracted_mo2="${downloaded_mo2%.*}"

# Initialize variables for the script extender, which may or may not be used depending on the presence of game_scriptextender_url.
downloaded_scriptextender=""
extracted_scriptextender=""

# If the game_scriptextender_url is set, define the paths for the downloaded and extracted script extender files.
if [ -n "$game_scriptextender_url" ]; then
	downloaded_scriptextender="$downloads_cache/${game_nexusid}_${game_scriptextender_url##*/}"
	extracted_scriptextender="${downloaded_scriptextender%.*}"
fi

# Define a function to purge the downloads cache. This function removes the downloaded and extracted files for the JDK, MO2, and script extender.
function purge_downloads_cache() {
	if [ -f "$downloaded_scriptextender" ]; then
		log_info "removing '$downloaded_scriptextender'"
		rm "$downloaded_scriptextender"

		if [ -d "$extracted_scriptextender" ]; then
			log_info "removing '$extracted_scriptextender'"
			rm -rf "$extracted_scriptextender"
		fi
	fi

	if [ -f "$downloaded_mo2" ]; then
		log_info "removing '$downloaded_mo2'"
		rm "$downloaded_mo2"

		if [ -d "$extracted_mo2" ]; then
			log_info "removing '$extracted_mo2'"
			rm -rf "$extracted_mo2"
		fi
	fi

	if [ -f "$downloaded_jdk" ]; then
		log_info "removing '$downloaded_jdk'"
		rm "$downloaded_jdk"

		if [ -d "$extracted_jdk" ]; then
			log_info "removing '$extracted_jdk'"
			rm -rf "$extracted_jdk"
		fi
	fi

	if [ -f "$downloaded_winetricks" ]; then
		log_info "removing '$downloaded_winetricks'"
		rm "$downloaded_winetricks"
	fi
}

# If the cache_enabled variable is set to "0", call the purge_downloads_cache function to clear the cache.
if [ "$cache_enabled" == "0" ]; then
	purge_downloads_cache
fi

# Set a flag to indicate that the download step has started.
started_download_step=1

# If the JDK file does not exist in the cache, download it and extract it.
if [ ! -f "$downloaded_jdk" ]; then
	"$download" "$jdk_url" "$downloaded_jdk"
	mkdir "$extracted_jdk"
	"$extract" "$downloaded_jdk" "$extracted_jdk"
fi

# If the MO2 file does not exist in the cache, download it and extract it.
if [ ! -f "$downloaded_mo2" ]; then
	"$download" "$mo2_url" "$downloaded_mo2"
	mkdir "$extracted_mo2"
	"$extract" "$downloaded_mo2" "$extracted_mo2"
fi

# If the Winetricks file does not exist in the cache, download it.
if [ ! -f "$downloaded_winetricks" ]; then
	"$download" "$winetricks_url" "$downloaded_winetricks"
fi

# Copy the downloaded Winetricks file to the shared directory and make it executable.
cp "$downloaded_winetricks" "$executable_winetricks"
chmod u+x "$executable_winetricks"

# If the script extender URL is set and the script extender file does not exist in the cache, download it and extract it.
if [ -n "$downloaded_scriptextender" ] && [ ! -f "$downloaded_scriptextender" ]; then
	"$download" "$game_scriptextender_url" "$downloaded_scriptextender"
	mkdir "$extracted_scriptextender"
	"$extract" "$downloaded_scriptextender" "$extracted_scriptextender"
fi
