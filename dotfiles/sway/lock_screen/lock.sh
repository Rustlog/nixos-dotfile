#!/usr/bin/env bash

set -x

builtin set -euo pipefail

function set_background() {
    hyprlock --config "${0%/*}/hyprlock.config" &
}

function turn_off_display() {
    # sleep 0.04 && swaymsg output '*' power off
    :
}

function main() {
    [[ "${1:-""}" == "set_bg" ]] && { set_background; return 0; }

    if command -v playerctl &> /dev/null && command -v playerctld &> /dev/null; then
        (playerctl --player=playerctld status 2>/dev/null | grep -q Playing) && return 0
    fi

    set_background

    turn_off_display
}

main "${@}"

