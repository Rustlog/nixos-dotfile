{ config, pkgs, lib, ... }:

{

    # programs modules
    programs = {
        sway.enable = true;
        hyprland.enable = true;
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
            settings = {
                main = {
                    term = "xterm-256color"; app-id = "foot"; title = "foot"; locked-title = 1;
                    font = "SourceCodePro:size=18:weight=bold:slant=Italic";
                    font-bold = "SourceCodePro:size=18:weight=bold:slant=Italic";
                    font-italic = "SourceCodePro:size=18:weight=bold:slant=Italic";
                    font-size-adjustment = "10%"; initial-window-size-pixels = "1200x600";
                };
                colors = {
                    regular1 = "F4005F"; regular2 = "A8E024"; regular3 = "FA8419";
                    regular4 = "9D65FF"; regular5 = "F4005F"; regular6 = "58D1EB";
                    regular7 = "C4C5B5"; bright1 = "F4005F"; bright2 = "A8E024";
                    bright3 = "FA8419"; bright4 = "9D65FF"; bright5 = "F4005F";
                    bright6 = "58D1EB"; bright7 = "C4C5B5";
                };
                csd = {
                    preferred = "none"; size = 16;
                };
                environment = {
                    EDITOR = "nvim"; COLORTERM = "truecolor";
                };
                mouse = {
                    hide-when-typing = true;
                };
            };
        };
    };

    # services module
    services = {
        displayManager = {
            ly.enable = true;
            ly.settings = {
                animation = "colormix";
                session_log = ".local/state/ly-session.log";
                vi_mode = true; full_color = true;
                clear_password = true;
            };
        };
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
    };

    # rtkit for pipewire
    security.rtkit.enable = true;

    # docker settings
    virtualisation = {
        docker = {
            enable = true;
            daemon.settings = {
                data-root = "/DT/containers/docker_containers/";
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
        "docker" = {
            wantedBy = lib.mkForce [];
        };
    };
}

