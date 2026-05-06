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
        --width 40 \
        --margin "1" \
        --padding "1" \
'
  ____  __  __             
 / __ \/ /_/ /  ___ _______
/ /_/ / __/ _ \/ -_) __(_-<
\____/\__/_//_/\__/_/ /___/
                             
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

# log dir
log_dir="$parent_dir/Logs"
log="$log_dir/others-$(date +%d-%m-%y).log"

# log directory
if [[ -f "$log" ]]; then
    errors=$(grep "ERROR" "$log")
    last_installed=$(grep "thunar-archive-plugin" "$log" | awk {'print $2'})
    if [[ -z "$errors" && "$last_installed" == "DONE" ]]; then
        msg skp "Skipping this script. No need to run it again..."
        sleep 1
        exit 0
    fi
else
    mkdir -p "$log_dir"
    touch "$log"
fi

main_packages=(
    curl
    fastfetch
    ffmpeg
    git
    grim
    imagemagick
    jq
    kitty
    qt5-style-kvantum
    less
    libx11-dev
    libxext-dev
    lxappearance
    make
    network-manager-gnome
    network-manager
    nodejs
    npm
    neovim
    nvtop
    pamixer
    parallel
    pciutils
    pavucontrol
    pipewire-alsa
    pipewire-bin
    pipewire-pulse
    power-profiles-daemon
    pulseaudio-utils
    python3-requests
    python3-dev
    python3-gi
    python3-pip
    python3-pil
    python3-pyquery
    qt5ct
    qt6ct
    libqt6svg6
    ripgrep
    slurp
    sway-notification-center
    tar
    unzip
    waybar
    wget
    wl-clipboard
    xdg-utils
    xfce-polkit
)

# other necessary packages
other_packages=(
    btop
    cava
    cliphist
    partitionmanager
    mpv
    mpv-mpris
    nwg-look
    pamixer
    wlogout
)

dolphin=(
    ark
    crudini
    dolphin
    gwenview
    okular
)

rofi_deps=(
	meson 
	ninja-build 
	pkg-config 
	bison 
	flex 
	libglib2.0-dev 
	libpango1.0-dev 
	libcairo2-dev 
	libgdk-pixbuf-2.0-dev 
	libstartup-notification0-dev 
	libxkbcommon-dev 
	libxkbcommon-x11-dev 
	libxcb1-dev 
	libxcb-keysyms1-dev 
	libxcb-xkb-dev 
	libxcb-randr0-dev 
	libxcb-xinerama0-dev 
	libxcb-icccm4-dev 
	libxcb-ewmh-dev 
	libxcb-cursor-dev 
	libxcb-util0-dev 
	wayland-protocols 
	libwayland-dev
)

awww_deps=(
	build-essential
	liblz4-dev
	libdrm-dev
	libgbm-dev
)

# url to install grimblast
grimblast_url=https://github.com/hyprwm/contrib.git

# checking already installed packages 
for skipable in "${main_packages[@]}" "${other_packages[@]}" "${dolphin[@]}"; do
    skip_installed "$skipable"
done

installble_main_pkg=($(printf "%s\n" "${main_packages[@]}" | grep -vxFf "$installed_cache"))
installble_other_pkg=($(printf "%s\n" "${other_packages[@]}" | grep -vxFf "$installed_cache"))
installble_dolphin_pkg=($(printf "%s\n" "${dolphin[@]}" | grep -vxFf "$installed_cache"))
installble_rofi_deps=($(printf "%s\n" "${rofi_deps[@]}" | grep -vxFf "$installed_cache"))
installble_awww_deps=($(printf "%s\n" "${awww_deps[@]}" | grep -vxFf "$installed_cache"))

printf "\n\n"

# installing necessary packages
for packages in "${installble_main_pkg[@]}" "${installble_other_pkg[@]}" "${installble_dolphin_pkg[@]}" "${installble_rofi_deps[@]}" "${installble_awww_deps[@]}"; do
  install_package "$packages"
  if dpkg -s "$packages" &> /dev/null; then
    echo "[ DONE ] - $packages was installed successfully!" 2>&1 | tee -a "$log" &> /dev/null
  else
    echo "[ ERROR ] - Sorry, could not install '$packages'" 2>&1 | tee -a "$log" &> /dev/null
  fi
done

# installing grimblast
if [ -f '/usr/local/bin/grimblast' ]; then
  msg dn "Grimblast is already installed..." 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")
else

  msg act "Installing Grumblast..."
  git clone --depth=1 "$grimblast_url" "$parent_dir/.cache/grimblast/" 2>&1 | tee -a "$log" &> /dev/null
  cd "$parent_dir/.cache/grimblast/grimblast"
  make 2>&1 | tee -a "$log" &> /dev/null
  sudo make install 2>&1 | tee -a "$log" &> /dev/null

  sleep 1
  rm -rf "$parent_dir/.cache/grimblast" 2>&1 | tee -a "$log"

	if [ -f '/usr/local/bin/grimblast' ]; then
	msg dn "Grimblast was installed successfully..."
	printf "[ DONE ] - Grimblast was installed successfully...\n" 2>&1 | tee -a "$log"
	fi
fi


if ! command -v rofi &> /dev/null; then
  msg act "Installing rofi..."
  rofi_ver="2.0.0"
  release_url="https://github.com/davatorium/rofi/releases/download/${rofi_ver}/rofi-${rofi_ver}.tar.xz"
  wget -O "$parent_dir/.cache/rofi-${rofi_ver}.tar.xz" "$release_url" 2>&1 | tee -a "$log"
  tar -C "$parent_dir/.cache" -xf "$parent_dir/.cache/rofi-${rofi_ver}.tar.xz" 2>&1 | tee -a "$log"
  cd "$parent_dir/.cache/rofi-${rofi_ver}"
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
  meson setup build --prefix /usr/local -Dxcb=enabled -Dwayland=enabled 2>&1 | tee -a "$log"
  ninja -C build 2>&1 | tee -a "$log"
  sudo ninja -C build install 2>&1 | tee -a "$log"
  msg dn "rofi was installed successfully..."
  printf "[ DONE ] - rofi was installed successfully...\n" 2>&1 | tee -a "$log"
else
  msg dn "rofi is already installed..."
  printf "[ DONE ] - rofi is already installed...\n" 2>&1 | tee -a "$log"
fi

# installing awww
if ! command -v swww &> /dev/null; then
  msg act "Installing swww..."

  awww_tag="v0.11.2"
  awww_dir="$parent_dir/.cache/awww"

  # ensure cargo exists (install rustup if missing)
  if ! command -v cargo &> /dev/null; then
    msg act "Installing Rust (rustup)..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y 2>&1 | tee -a "$log"
  fi

  # load rust environment if available
  if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
  fi

  # final verification
  if ! command -v cargo &> /dev/null; then
    echo "[ ERROR ] cargo not found after rust setup!" | tee -a "$log"
    exit 1
  fi

  # ensure correct rust version
  rustup update 2>&1 | tee -a "$log"

  # clone correct version
  rm -rf "$awww_dir"
  git clone --branch "$awww_tag" --depth=1 https://codeberg.org/LGFae/awww.git "$awww_dir" \
    2>&1 | tee -a "$log"

  cd "$awww_dir" || exit 1

  # build
  cargo build --release 2>&1 | tee -a "$log" || {
    echo "[ ERROR ] swww build failed!" | tee -a "$log"
    exit 1
  }

  # install binaries
  sudo cp target/release/swww /usr/local/bin/
  sudo cp target/release/swww-daemon /usr/local/bin/

  # cleanup
  cd ~
  rm -rf "$awww_dir"

  # verify
  if command -v swww &> /dev/null; then
    printf "[ DONE ] - swww was installed successfully...\n" | tee -a "$log"
  else
    printf "[ ERROR ] - swww installation failed!\n" | tee -a "$log"
    exit 1
  fi

else
  msg dn "awww is already installed..."
fi

exit 0

sleep 1 && clear

"$dir/pywal.sh" 2>&1 | tee -a >(sed 's/\x1B\[[0-9;]*[JKmsu]//g' >> "$log")