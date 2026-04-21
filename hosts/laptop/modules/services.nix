{ pkgs, lib, ... }:

{
    # programs modules
    programs = {
        sway = {
            enable = true; # sway WM
            extraOptions = [ "--unsupported-gpu" ];
            extraSessionCommands = ''
                export GTK_THEME=Breeze:dark
                export QT_QPA_PLATFORMTHEME=qt6ct
                export WLR_RENDERER=vulkan
            '';
        };
        hyprland.enable = true; # hyprland WM

        git.enable = true;
        bash.enable = true;
        bash.completion.enable = true;
        zsh.enable = true;
        wireshark.enable = true;
        dconf.enable = true;
        nix-ld = {
            enable = true;
            libraries = with pkgs; [
                gtk4 gtk3 glib libGL mesa cairo pango
                libdrm alsa-lib pciutils libx11 libxcb
                libxcb-util libxext libxrandr
                libxcomposite libxcursor libxdamage
                libxfixes libxi gdk-pixbuf atk
                adwaita-icon-theme dbus-glib libxt
                ffmpeg libva libvdpau libvpx libopus
            ];
        };
        foot = {
            enable = true;
            settings = (import ./foot.ini.nix);
        };
    };

    # services module
    services = {
        displayManager = {
            # ly.enable = true;
            # ly.settings = {
            #     animation = "colormix";
            #     session_log = ".local/state/ly-session.log";
            #     vi_mode = true; full_color = true;
            #     clear_password = true;
            # };
            sddm = {
                enable = true;
                wayland.enable = true;
                wayland.compositor = "weston";
                theme = "sddm-astronaut-theme";
                extraPackages = with pkgs; [
                    kdePackages.qtmultimedia
                    kdePackages.qtvirtualkeyboard
                    kdePackages.kirigami kdePackages.qtsvg
                    kdePackages.qt5compat sddm-astronaut
                ];
            };
        };
        power-profiles-daemon.enable = false;
        desktopManager.plasma6.enable = true; # KDE plasma6
        tlp.enable = true;
        libinput.enable = true;
        xserver.enable = false;
        udisks2.enable = true;
        openssh = {
            enable = true;
            settings = {
                Port = 22;
                PasswordAuthentication = false;
                PubkeyAuthentication = true;
            };
        };
        pipewire = {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
        };
        logind = {
            settings.Login = {
                HandleLidSwitch = "ignore";
                HandleLidSwitchExternalPower = "ignore";
            };
        };
        adguardhome = {
            enable = true;
            extraArgs = [ "--web-addr" "127.0.0.1:4000" ];
        };
        journald.extraConfig = ''
            Storage=volatile
            SystemMaxUse=100M
            RuntimeMaxUse=100M
        '';
    };

    # rtkit for pipewire
    security.rtkit.enable = true;

    # docker settings
    virtualisation = {
        docker = {
            enable = true;
            daemon.settings = {
                data-root = "/shared/containers/docker_containers/";
                storage-driver = "overlay2";
            };
        };
        podman = {
            enable = false;
        };
    };

    # custom systemd services
    systemd.services = {
        "nbfc-service" = {
            enable = true;
            description = "nbfc: Notebook fan control";
            documentation = [ "man:nbfc_service(1)" ];
            after = [ "network.target" ];
            unitConfig = {
                StartLimitIntervalSec = 20;
                StartLimitBurst = 5;
            };
            serviceConfig = {
                ExecStart = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file /var/nbfc/nbfc.json";
                Restart = "always";
                RestartSec = 1;
            };
            wantedBy = [ "multi-user.target" ];
        };
        "ryzenprofile" = {
            enable = true;
            description = "ryzenprofile: ";
            documentation = [ "man:ryzenprofile(1)" ];
            unitConfig = {
                StartLimitIntervalSec = 20;
                StartLimitBurst = 5;
            };
            serviceConfig = {
                ExecStart = "/usr/local/bin/ryzenprofiled";
                Restart = "always";
                RestartSec = 1;
            };
            wantedBy = [ "multi-user.target" ];
        };
        "vtconsole_font" = {
            enable = true;
            description = "vtconsole font";
            unitConfig = {
                Requires = [ "systemd-vconsole-setup.service" ];
                After = [ "systemd-vconsole-setup.service" ];
                Before = [ "displayManager.service" ];
            };
            serviceConfig = {
                ExecStart = ''
                    /bin/sh -c \
                        'CONFIG="/etc/vtconsole.conf" VTs="/dev/tty[0-9]" FONT="ter-v24b"; \
                        [ -r "$''${CONFIG}" ] && . "$''${CONFIG}"; \
                        for tty in $''${VTs}; do \
                            [ -c "$''${tty}" ] || continue; \
                            until ${pkgs.kbd}/bin/setfont -C "$''${tty}" "$''${FONT}"; do \
                                ${pkgs.coreutils-full}/bin/sleep 0.1; \
                            done \
                        done'
                '';
                Type = "oneshot";
                Restart = "no";
            };
            wantedBy = [ "multi-user.target" ];
        };
        "docker" = {
            wantedBy = lib.mkForce [];
        };
    };
}

