#!/usr/bin/env bash

# Define the installation directory for Mod Organizer 2
mo2_installation="$install_dir/modorganizer2"

# Function to install Mod Organizer 2
function install_mo2() {
    # Log the installation process
    log_info "installing Mod Organizer 2 in '$mo2_installation'"
    # Create the installation directory if it doesn't exist
    mkdir -p "$mo2_installation"
    # Copy all files from the extracted Mod Organizer 2 directory to the installation directory
    cp -af "$extracted_mo2/." "$mo2_installation"
}

# Function to check if Mod Organizer 2 should be installed or updated
function check_should_install_mo2() {
    local should_install=0

    # Check if the extracted Mod Organizer 2 directory exists
    if [ -d "$extracted_mo2" ]; then
        # Check if the Mod Organizer 2 installation directory already exists
        if [ -d "$mo2_installation" ]; then
            # Ask the user if they want to update Mod Organizer 2
            confirm_update=$( \
                "$dialog" question \
                    "Mod Organizer 2 is already installed.\nWould you like to update?" \
            )

            # If the user confirms the update, set should_install to 1
            if [ "$confirm_update" == "0" ]; then
                should_install=1
            else
                # Log that the update is being skipped
                log_info "skipping Mod Organizer 2 update"
            fi
        else
            # If the installation directory does not exist, set should_install to 1
            should_install=1
        fi
    fi

    # Return the value of should_install
    echo "$should_install"
    return 0
}

# Check if Mod Organizer 2 should be installed or updated and store the result
should_install_mo2=$(check_should_install_mo2)

# Function to install various files including JDK, Mod Organizer 2, and script extender
function install_files() {
    # Check if the extracted JDK directory exists
    if [ -d "$extracted_jdk" ]; then
        # Define the JDK installation directory
        jdk_installation="$game_prefix/drive_c/java"

        # Check if the JDK installation directory already exists
        if [ -d "$jdk_installation" ]; then
            # Log the removal of the existing JDK installation
            log_info "removing existing JDK installation in '$jdk_installation'"
            rm -rf "$jdk_installation/*"
        else
            # Create the JDK installation directory if it doesn't exist
            mkdir "$jdk_installation"
        fi

        # Log the installation of the JDK
        log_info "installing JDK in '$jdk_installation'"
        # Copy all files from the extracted JDK directory to the JDK installation directory
        cp -R --no-preserve=mode,ownership "$extracted_jdk"/* "$jdk_installation"
    fi

    # Check if Mod Organizer 2 should be installed
    if [ "$should_install_mo2" == "1" ]; then
        install_mo2
    fi

    # Check if the extracted script extender directory exists
    if [ -d "$extracted_scriptextender" ]; then
        # Log the installation of the script extender
        log_info "installing script extender in '$game_installation'"

        # Check if all files should be copied from the script extender directory
        if [ "${game_scriptextender_files[*]}" == "*" ]; then
            # Log the copying of all files from the script extender directory
            log_info "copying all files from '$extracted_scriptextender' into '$game_installation'"
            cp -an "$extracted_scriptextender"/* "$game_installation" || true
        else
            # Loop through each file specified for copying
            for scriptextender_file in "${game_scriptextender_files[@]}"; do
                # Define the full path of the script extender file
                scriptextender_filepath="$extracted_scriptextender/$scriptextender_file"
                # Log the copying of the specific file
                log_info "copying '$scriptextender_filepath' into '$game_installation'"
                cp -an "$scriptextender_filepath" "$game_installation" || true
            done
        fi
    fi
}

# Call the install_files function and display a loading dialog
install_files \
    | "$dialog" loading "Installing necessary files\nThis shouldn't take long"
