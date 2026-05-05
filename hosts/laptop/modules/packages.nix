{ pkgs, zen-browser, ... }:

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
        cppcheck go gh

        # wayland and session tools
        # sway & hyprland
        swayidle hyprlock swaylock swayimg cage
        mako wlrctl wlr-randr swww foot alacritty
        hyprland hypridle hyprlock colord waybar
        fuzzel wl-clipboard grim slurp wf-recorder
        bemoji

        # kde plasma
        kdePackages.plasma-workspace

        # audio video and media stuff
        vlc feh imv inxi mpv mpvScripts.mpris obs-studio
        alsa-lib alsa-utils alsa-tools alsa-firmware
        libao calf easyeffects pavucontrol lsp-plugins
        cava librewolf firefox-bin playerctl jellyfin
        jellyfin-web mpd ncmpcpp
        zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        # DAWs
        lmms ardour hydrogen carla

        # essential tools
        bash-completion
        zsh-syntax-highlighting pipx kdePackages.kate
        neovim vim nano micro-full ripgrep yazi tmux jq
        rsync bat eza lsd fzf ncdu dust gdu

        # language servers
        bash-language-server
        nil # nix language
        lua-language-server
        typescript-language-server
        rust-analyzer
        gopls
        vscode-langservers-extracted
        yaml-language-server
        nginx-language-server
        pyright

        # graphics productivity
        blender krita gimp inkscape

        # system tools
        ryzenadj brightnessctl mesa
        exfatprogs e2fsprogs ntfs3g dosfstools
        vulkan-tools vulkan-loader vulkan-headers
        nbfc-linux grub2 qutebrowser glib lvm2 lsof
        openssl gsettings-desktop-schemas xorg.xinit
        xorg.xorgserver xorg.xinput xorg.xrandr
        powertop ffmpeg-full zbar wireguard-tools
        openvpn file libva libvdpau libvpx libopus
        nvtopPackages.full curl wget pciutils
        gammastep jq most nix-tree nix-index
        man-pages man-pages-posix gptfdisk gnupg
        smartmontools bc psmisc
        nginx apacheHttpd
        qemu_full steam-run

        # networking
        networkmanager dig wirelesstools
        sshfs nftables frp nmap net-tools
        networkmanagerapplet mtpfs simple-mtpfs
        nmon dnsmasq hostapd protonvpn-gui
        iw iproute2 ethtool

        # utilities, tools, themes and extras
        zstd imagemagick numactl cameractrls exiftool
        chafa fastfetch pastel guvcview tree p7zip
        shellcheck htop btop atop iftop tor nload obsidian
        tor-browser procs yt-dlp efibootmgr duf graphviz-nox
        wofi wofi-emoji emote rofi rofi-emoji gtypist cloc
        libnotify lxappearance kdePackages.qt6ct pandoc
        kdePackages.breeze kdePackages.breeze-gtk
        kdePackages.breeze-icons kdePackages.dolphin
        kdePackages.dolphin-plugins kdePackages.konsole
        kdePackages.kio-extras cameractrls-gtk4 udisks
        kdePackages.okular kdePackages.qttools pomodoro
        kdePackages.kdeconnect-kde kdePackages.kclock
        kdePackages.kcolorchooser pastel lf
        powershell gnome-pomodoro
        ferdium

        # sddm displaymanager
        kdePackages.sddm kdePackages.qtmultimedia
        kdePackages.kirigami kdePackages.qtvirtualkeyboard
        kdePackages.qt5compat kdePackages.qtsvg
        sddm-astronaut

        # just in case, if needed
        wireshark termshark qbittorrent

        # containers and LLMs
        docker podman ollama
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

