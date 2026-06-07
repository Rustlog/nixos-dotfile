#!/usr/bin/env bash

set -euo pipefail

function log() {
    printf '[%s]: %s\n' "${1}" "${2}"
    [[ "${1}" == "fatal" ]] && exit ${3:-1}
}

function Install() {
    local msg="$1"
    shift
    local -a tools=("$@")
    log info "${msg}"
    dnf update -y
    dnf install -y "${tools[@]}"
}

function DevTools() {
    local msg="Installing dev tools"
    local -a tools=(
        git vim nano curl wget
        python3 python3-pip nodejs
        npm neovim bat fzf
        fd-find  # provides 'fd' command
        eza      # modern ls alternative (needs copr repo)
        lsd      # another ls alternative
        zsh tldr
    )
    Install "${msg}" "${tools[@]}"
}

function Server() {
    local msg="Installing server core and essential tools"
    local -a tools=(
        openssh-server nginx
        firewalld  # Fedora's alternative to ufw
        net-tools htop iproute2
        rsync atop glances btop
        nvtop    # GPU monitoring (CLI)
        docker nmap tcpdump
        bind-utils  # Fedora's equivalent to bind9 tools
        vsftpd tor
    )
    Install "${msg}" "${tools[@]}"
}

function Build() {
    local msg="Installing build tools"
    local -a tools=(
        @development-tools  # Fedora group for build-essential equivalent
        gcc gcc-c++     # Fedora's name for g++
        make cmake autoconf automake
        clang llvm rust cargo
    )
    Install "${msg}" "${tools[@]}"
}

function Environment() {
    local msg="Installing environment tools"
    local -a tools=(
        docker docker-compose python3-venv
        python3-virtualenv jq
        lazydocker  # needs copr repo
        python3-pipx ansible
    )
    Install "${msg}" "${tools[@]}"
}

function Productivity() {
    local msg="Installing productivity tools"
    local -a tools=(
        tmux screen zip unzip tree
        bash-completion cowsay figlet
        cmatrix sl
        fastfetch  # modern neofetch alternative
        dust      # du alternative
        duf       # df alternative
        gdu       # ncdu alternative (interactive)
        dua-cli   # another du analyzer (needs copr repo)
        procs     # ps alternative
        micro     # simple editor
        ranger    # file manager (CLI)
        yt-dlp
        pv        # pipe viewer
        pigz      # parallel gzip
        whois
        lynx      # text browser
        mtr
        stress-ng
        sysstat   # iostat, sar, etc.
        iotop
    )
    Install "${msg}" "${tools[@]}"
}

function main() {
    [[ $# -eq 0 ]] && log fatal "No arguments given. Usage: ${0##*} [dev|server|build|env|prod|all]"

    log info "Starting setup for Fedora"
    dnf update -y

    case "$1" in
        dev) DevTools ;;
        server) Server ;;
        build) Build ;;
        env) Environment ;;
        prod) Productivity ;;
        all)
            DevTools
            Server
            Build
            Environment
            Productivity
            ;;
        *)
            log fatal "Invalid argument: $1. Use: dev, server, build, env, prod, or all"
            ;;
    esac

    log info "Setup completed successfully"
}

main "$@"

