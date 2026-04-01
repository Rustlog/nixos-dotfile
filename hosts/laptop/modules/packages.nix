{ config, lib, pkgs, ... }:

{
    nixpkgs.config.allowUnfree = true;

    # system packages
    environment.systemPackages = with pkgs; [

        # dev tools
        nasm gcc zig clang clang-tools
        libllvm llvm-manpages nodejs
        postgresql sqlite gnumake deno
        gdb gdbgui valgrind traceroute
        stdman cppreference-doc python3

        # wayland and session tools
        swayidle hyprlock swaylock swayimg
        mako wlrctl wlr-randr swww foot alacritty
        hyprland hypridle hyprlock colord waybar
        fuzzel wl-clipboard grim slurp wf-recorder

        # audio video and media stuff
        vlc feh imv inxi mpv mpvScripts.mpris obs-studio
        alsa-lib alsa-utils alsa-tools alsa-firmware
        libao calf easyeffects pavucontrol lsp-plugins
        cava librewolf playerctl jellyfin jellyfin-web
        mpd ncmpcpp
        # DAWs
        lmms ardour hydrogen carla

        # essential tools
        bash-completion bash-language-server
        zsh-syntax-highlighting pipx
        neovim vim nano ripgrep yazi tmux jq
        rsync bat eza lsd fzf ncdu dust gdu

        # graphics productivity
        blender krita gimp inkscape

        # system tools
        ryzenadj brightnessctl mesa mesa-demos
        exfatprogs e2fsprogs ntfs3g dosfstools
        vulkan-tools vulkan-loader vulkan-headers
        nbfc-linux grub2 qutebrowser glib lvm2 lsof
        openssl gsettings-desktop-schemas xorg.xinit
        xorg.xorgserver xorg.xinput xorg.xrandr
        powertop ffmpeg-full zbar wireguard-tools
        openvpn file libva libvdpau libvpx libopus
        nvtopPackages.full curl wget pciutils
        gammastep jq most nix-tree nix-index
        man-pages man-pages-posix

        # networking
        networkmanager dig wirelesstools
        sshfs nftables frp nmap net-tools
        networkmanagerapplet mtpfs simple-mtpfs
        nmon dnsmasq hostapd protonvpn-gui

        # utilities, tools, themes and extras
        zstd imagemagick numactl cameractrls
        chafa fastfetch pastel guvcview tree
        shellcheck htop btop atop iftop tor nload
        tor-browser procs yt-dlp efibootmgr duf
        wofi wofi-emoji emote smile rofi rofi-emoji
        libnotify lxappearance kdePackages.qt6ct
        kdePackages.breeze kdePackages.breeze-gtk
        kdePackages.breeze-icons kdePackages.dolphin
        kdePackages.dolphin-plugins kdePackages.konsole
        kdePackages.kio-extras cameractrls-gtk4 udisks
        kdePackages.okular kdePackages.qttools
        kdePackages.kdeconnect-kde kdePackages.kclock

        # just in case, if needed
        wireshark termshark qbittorrent

        # admin toolbox
        nginx apacheHttpd
        docker podman
        qemu_full

    ];

    # system fonts
    fonts.packages = with pkgs; [
        source-code-pro font-awesome
        noto-fonts-color-emoji
        noto-fonts noto-fonts-cjk-sans
        nerd-fonts.hack roboto-mono
        nerd-fonts.roboto-mono
    ];
}

