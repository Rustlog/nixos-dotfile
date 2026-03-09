{ config, lib, pkgs, ... }:

{
    # programs modules
    programs = {
        sway.enable = true;
        git.enable = true;
        bash.enable = true;
        zsh.enable = true;
        dconf.enable = true;
        nix-ld = {
            enable = true;
            libraries = with pkgs; [
                gtk4 gtk3 glib libGL mesa cairo pango
                libdrm alsa-lib pciutils libx11 libxcb
                libxcb-util libxext libxrandr
                libxcomposite libxcursor libxdamage
                libxfixes libxi gdk-pixbuf atk
                adwaita-icon-theme
                dbus-glib libxt
            ];
        };
    };

    # system packages
    environment.systemPackages = with pkgs; [

        # wayland and session tools
        swayidle hyprlock swaylock swayimg
        mako wlrctl wlr-randr swww foot alacritty
        hyprland hypridle hyprlock colord waybar
        fuzzel wl-clipboard

        # audio video and media stuff
        vlc mpv mpvScripts.mpris feh imv inxi
        alsa-lib alsa-utils alsa-tools alsa-firmware
        libao calf easyeffects pavucontrol
        lsp-plugins cava librewolf playerctl

        # daily workflow tools
        bash-completion bash-language-server
        zsh-syntax-highlighting
        neovim vim nano ripgrep yazi tmux jq
        rsync bat eza lsd fzf ncdu dust gdu

        # graphics productivity
        blender krita gimp inkscape

        # system tools
        ryzenadj brightnessctl mesa mesa-demos
        exfatprogs e2fsprogs ntfs3g dosfstools
        vulkan-tools vulkan-loader vulkan-headers
        nbfc-linux grub2 qutebrowser glib lvm2
        openssl gsettings-desktop-schemas xorg.xinit
        xorg.xorgserver xorg.xinput xorg.xrandr

        # networking
        networkmanager dig wirelesstools
        sshfs nftables frp nmap net-tools
        networkmanagerapplet mtpfs simple-mtpfs
        nmon dnsmasq hostapd

        # dev tools
        nasm gcc zig clang clang-tools
        libllvm llvm-manpages
        postgresql sqlite

        # utilities
        zstd imagemagick numactl cameractrls
        chafa fastfetch pastel guvcview tree
        shellcheck htop btop atop iftop tor
        tor-browser procs yt-dlp efibootmgr duf
        wofi wofi-emoji emote smile rofi rofi-emoji
        libnotify lxappearance kdePackages.qt6ct
        kdePackages.breeze kdePackages.breeze-gtk
        kdePackages.breeze-icons

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

