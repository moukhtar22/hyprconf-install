#!/bin/bash

#### Advanced Hyprland Installation Script by ####
#### Shell Ninja ( https://github.com/shell-ninja ) ####

# color definition
red="\e[1;31m"
green="\e[1;32m"
yellow="\e[1;33m"
blue="\e[1;34m"
magenta="\e[1;1;35m"
cyan="\e[1;36m"
orange="\e[1;38;5;214m"
end="\e[1;0m"

display_text() {
    gum style \
        --border rounded \
        --align center \
        --width 60 \
        --margin "1" \
        --padding "1" \
'
   __ __              __             __
  / // /_ _____  ____/ /__ ____  ___/ /
 / _  / // / _ \/ __/ / _ `/ _ \/ _  / 
/_//_/\_, / .__/_/ /_/\_,_/_//_/\_,_/  
     /___/_/                           
'
}

clear && display_text
printf " \n \n"

###------ Startup ------###

# install script dir
dir="$(dirname "$(realpath "$0")")"
source "$dir/1-global_script.sh"

parent_dir="$(dirname "$dir")"
source "$parent_dir/interaction_fn.sh"

# skip installed cache
cache_dir="$parent_dir/.cache"
installed_cache="$cache_dir/installed_packages"

# log directory
log_dir="$parent_dir/Logs"
log="$log_dir/hyprland-$(date +%d-%m-%y).log"

if [[ -f "$log" ]]; then
    errors=$(grep "ERROR" "$log")
    last_installed=$(grep "hyprsunset" "$log" | awk {'print $2'})
    if [[ -z "$errors" && "$last_installed" == "DONE" ]]; then
        msg skp "Skipping this script. No need to run it again..."
        sleep 1
        exit 0
    fi
else
    mkdir -p "$log_dir"
    touch "$log"
fi

_hypr=(
    hyprland
    hyprlock
    hypridle
)

# checking already installed packages 
for skipable in "${_hypr[@]}"; do
    skip_installed "$skipable"
done

to_install=($(printf "%s\n" "${_hypr[@]}" | grep -vxFf "$installed_cache"))

printf "\n\n"

# Check for Debian 13 (trixie)
is_debian_13=false
if grep -qiE 'trixie|version_id="?13"?' /etc/os-release 2>/dev/null; then
    is_debian_13=true
fi

if [[ "$is_debian_13" == true ]]; then
    if ! grep -q "^deb.*trixie-backports" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        msg act "Adding trixie-backports repository for Hyprland..."
        echo "deb http://deb.debian.org/debian trixie-backports main contrib non-free non-free-firmware" | sudo tee /etc/apt/sources.list.d/trixie-backports.list > /dev/null
        sudo apt-get update
    fi
fi

# Installation of Hyprland basics
for hypr_pkgs in "${to_install[@]}"; do
    msg act "Installing $hypr_pkgs..."
    if [[ "$is_debian_13" == true ]]; then
        sudo apt-get install -y -t trixie-backports "$hypr_pkgs"
    else
        sudo apt-get install -y "$hypr_pkgs"
    fi

    if dpkg -s "$hypr_pkgs" &> /dev/null; then
        echo "[ DONE ] - '$hypr_pkgs' was installed successfully!" 2>&1 | tee -a "$log" &> /dev/null
    else
        echo "[ ERROR ] - Sorry, could not install '$hypr_pkgs'" 2>&1 | tee -a "$log" &> /dev/null
    fi
done

# installing pyprland
if ! command -v pypr &> /dev/null; then
    msg act "Installing pyprland..."
    sudo apt-get install -y python3-pip pipx
    pipx install pyprland 2>&1 | tee -a "$log"
    pipx ensurepath 2>&1 | tee -a "$log"

    if command -v pypr &> /dev/null; then
        msg dn "pyprland was installed successfully!"
    else
        msg err "pyprland failed to install..."
    fi
else
    msg dn "pyprland is already installed..."
fi

# building hyprsunset
if ! command -v hyprsunset &> /dev/null; then
    msg act "Building hyprsunset..."
    sudo apt-get install -y cmake pkg-config libwayland-dev wayland-protocols libxkbcommon-dev
    git clone --depth=1 https://github.com/hyprwm/hyprsunset.git "$parent_dir/.cache/hyprsunset" 2>&1 | tee -a "$log"
    cd "$parent_dir/.cache/hyprsunset"
    cmake -B build 2>&1 | tee -a "$log"
    sudo cmake --build build --target install 2>&1 | tee -a "$log"
    cd ~
    rm -rf "$parent_dir/.cache/hyprsunset"

    if command -v hyprsunset &> /dev/null; then
        msg dn "hyprsunset was installed successfully!"
    else
        msg err "hyprsunset failed to install..."
    fi
else
    msg dn "hyprsunset is already installed..."
fi

# building hyprcursor
if ! command -v hyprcursor &> /dev/null; then
    msg act "Building hyprcursor..."
    sudo apt-get install -y cmake pkg-config libzip-dev librsvg2-dev libtomlplusplus-dev libcairo2-dev
    git clone --depth=1 https://github.com/hyprwm/hyprcursor.git "$parent_dir/.cache/hyprcursor" 2>&1 | tee -a "$log"
    cd "$parent_dir/.cache/hyprcursor"
    cmake -B build 2>&1 | tee -a "$log"
    sudo cmake --build build --target install 2>&1 | tee -a "$log"
    cd ~
    rm -rf "$parent_dir/.cache/hyprcursor"

    if command -v hyprcursor &> /dev/null; then
        msg dn "hyprcursor was installed successfully!"
    else
        msg err "hyprcursor failed to install..."
    fi
else
    msg dn "hyprcursor is already installed..."
fi

sleep 1 && clear
