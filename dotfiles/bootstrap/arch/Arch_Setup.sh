#!/usr/bin/env bash

# Package Groups
SWAY_PKGS=(sway swaybg swayidle swaylock swaync swayimg sway-contrib)
I3_PKGS=(i3-wm i3lock i3status i3blocks i3status-rust)
TERM_PKGS=(alacritty konsole foot)
DEV_PKGS=(git vim neovim curl)

# Configuration Paths
CONFIG_MAP=(
    "../sway_config/config:$HOME/.config/sway/config"
    "../sway_config/wallpapers:$HOME/.config/sway/wallpapers"
    "../sway_config/foot/foot.ini:$HOME/.config/foot/foot.ini"
    "../waybar_config/style.css:$HOME/.config/waybar/style.css"
    "../waybar_config/config.jsonc:$HOME/.config/waybar/config.jsonc"
    "../i3_config:$HOME/.config/i3"
)

# Colors
GREEN="\033[38;2;120;200;120m"
YELLOW="\033[38;2;255;230;140m"
RED="\033[38;2;255;50;50m"
NC="\033[0m"


# Logging
LOG()    { printf "[%bLOG%b]: %s\n" "$GREEN" "$NC" "$1"; }
WARN()   { printf "[%bWARN%b]: %s\n" "$YELLOW" "$NC" "$1"; }
ERROR()  { printf "[%bERROR%b]: %s\n" "$RED" "$NC" "$1" >&2; }

# Require Arch
command -v pacman >/dev/null || {
    ERROR "This script is for Arch-based systems only."
    exit 1
}

# Prompts
prompt_yesno() {
    local msg="$1"
    read -rp "$msg (y/n): " ans
    [[ "$ans" =~ ^([yY]|)$ ]] && return 0 || return 1
}

# Package Installers
pkg_install() {
    sudo pacman -S --needed --noconfirm "$@" || {
        ERROR "Failed to install: $*"
        exit 1
    }
}

group_install() {
    local name="$1"; shift
    LOG "Installing: $name"
    pkg_install "$@"
}

# Safe File/Directory Copy
safe_copy() {
    local src="$1" dst="$2"

    if [[ -e "$dst" ]]; then
        prompt_yesno "$dst exists. Backup and overwrite?" && mv "$dst" "$dst.bak" || return
    fi

    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst" || {
        ERROR "Failed to copy $src -> $dst"
        exit 1
    }
}

# Vim/Neovim Setup
setup_editors() {
    safe_copy "../vim_config/vimrc" "$HOME/.vimrc"
    safe_copy "../neovim_config/init.vim" "$HOME/.config/nvim/init.vim"

    /usr/bin/vim -c "InstallPlug | q | q"
    /usr/bin/vim -c "PlugUpdate | q | q"
    /usr/bin/nvim -c "InstallPlug | q | q"
    /usr/bin/nvim -c "PlugUpdate | q | q"
}

# Execute
prompt_yesno "Install software packages?" && {
    group_install "Sway" "${SWAY_PKGS[@]}"
    group_install "I3" "${I3_PKGS[@]}"
    group_install "Terminals" "${TERM_PKGS[@]}"
    group_install "Dev Tools" "${DEV_PKGS[@]}"
}

prompt_yesno "Copy configuration files?" && {
    for map in "${CONFIG_MAP[@]}"; do
        IFS=$':' read -r src dst <<< "$map"
        safe_copy "$src" "$dst"
    done
}

prompt_yesno "Set up Vim and Neovim?" && setup_editors

LOG "System setup complete."

