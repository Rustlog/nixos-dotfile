{ pkgs, unstable-pkgs, lib, ... }:
let
    win10_package = (
    let
        pkg_name = "win10";
        weston_config = (pkgs.formats.ini {}).generate "weston_config" {
            libinput = {
                enable-tap = true;
                accel-profile= "adaptive";
                accel-speed= "0.6";
                natural-scroll = true;
                scroll-method = "two-finger";
            };
            keyboard = {
                repeat-rate = 60;
                repeat-delay = 240;
                keymap_layout = "us";
                numlock-on = true;
                vt-switching = true;
            };
        };
        win10_launcher = pkgs.writeScriptBin "${pkg_name}" ''
        #!${pkgs.bash}/bin/bash

        RAM="$(${pkgs.gawk}/bin/awk '/MemTotal/ { mem = $2/(1024) } END { printf "%dM\n", mem/2 }' /proc/meminfo)"
        RAM="''${RAM:-4G}"
        VCPUS="$(($(nproc)/2))"
        VCPUS="''${VCPUS:-4}"

        exec ${pkgs.weston}/bin/weston \
                --shell=kiosk-shell.so \
                --backend=drm \
                --xwayland \
                --config=${weston_config} -- \
        ${pkgs.qemu_full}/bin/qemu-system-x86_64 \
            -enable-kvm \
            -m "''${RAM}" \
            -cpu EPYC,vendor=AuthenticAMD,kvm=on \
            -smp cpus="''${VCPUS}",sockets=1 \
            -display gtk,gl=on,zoom-to-fit=on,show-menubar=off \
            -device virtio-gpu-gl-pci,max_outputs=1 \
            -netdev user,id=nat0 \
            -device virtio-net-pci,netdev=nat0 \
            -audiodev pipewire,id=snd0,out.latency=20000 \
            -device ich9-intel-hda -device hda-output,audiodev=snd0 \
            -usb -device usb-tablet \
            -drive file=/var/lib/qemu-vm/win10.qcow2,format=qcow2,if=virtio,media=disk
        '';
        win10_desktop = pkgs.writeTextDir "share/wayland-sessions/${pkg_name}.desktop" ''
            [Desktop Entry]
            Name=Win 10
            Comment=Boot into Win10
            Exec=${win10_launcher}/bin/${pkg_name}
            Type=Application
        '';
    in
    pkgs.symlinkJoin {
        name = pkg_name;
        paths = [ win10_launcher win10_desktop ];
    }).overrideAttrs (old: {
        passthru = (old.passthru or {}) // {
            providedSessions = [ old.name ];
        };
    });
in {
    # disable default services
    services.geoclue2.enable = false;

    # programs modules
    programs = {
        sway = {
            enable = true; # sway WM
            extraOptions = [ "--unsupported-gpu" ];
            package = unstable-pkgs.sway;
            extraSessionCommands = ''
                export GTK_THEME=Breeze:dark
                export QT_QPA_PLATFORMTHEME=qt6ct
                export WLR_RENDERER=vulkan
            '';
        };
        hyprland = {
            enable = true; # hyprland WM
            package = unstable-pkgs.hyprland;
        };

        git = {
            enable = true;
            lfs.enable = true;
            package = unstable-pkgs.git;
        };
        bash = {
            enable = true;
            completion.enable = true;
        };
        zsh.enable = true;
        wireshark.enable = true;
        dconf.enable = true;
        nix-ld = {
            enable = true;
            libraries = with pkgs; [
                gtk4 gtk3 glib libGL mesa cairo pango
                libdrm alsa-lib pciutils libx11 libxcb
                libxcb-util libxext libxrandr libxrender
                libxcomposite libxcursor libxdamage
                libxfixes libxi gdk-pixbuf atk libxtst
                adwaita-icon-theme dbus-glib libxt
                ffmpeg libva libvdpau libvpx libopus
                nss nspr dbus expat libdrm gdk-pixbuf
                cups libgbm libxscrnsaver
            ];
        };
        foot = {
            enable = true;
            settings = (import ./configs/foot.ini.nix);
        };
    };

    environment.systemPackages = [ win10_package ];

    # services module
    services = {
        displayManager = {
            ly.enable = true;
            ly.settings = {
                animation = "none";
                session_log = ".local/state/ly-session.log";
                clear_password = true;
                save = true;
                vi_mode = true; full_color = true;
                vi_default_mode = "insert";
            };
            # sddm = {
            #     enable = true;
            #     wayland.enable = true;
            #     wayland.compositor = "weston";
            #     theme = "sddm-astronaut-theme";
            #     extraPackages = with pkgs; [
            #         kdePackages.qtmultimedia
            #         kdePackages.kirigami kdePackages.qtsvg
            #         kdePackages.qt5compat sddm-astronaut
            #     ];
            # };
            sessionPackages = [
                win10_package
            ];
        };
        power-profiles-daemon.enable = false;
        desktopManager.plasma6.enable = true; # KDE plasma6
        tlp.enable = true;
        libinput.enable = true;
        xserver.enable = false;
        udisks2.enable = true;
        cron.enable = true;
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
            alsa.support32Bit = true;
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
    # Policy Kit
    security.polkit.enable = true;

    # docker settings
    virtualisation = {
        docker = {
            enable = true;
            daemon.settings = {
                data-root = "/shared/containers/docker_containers/";
                storage-driver = "overlay2";
            };
        };
        podman.enable = true;
        containers.storage.settings = {
            storage = {
                driver = "overlay";
                runroot = "/run/containers/storage/";
                graphroot = "/shared/containers/podman_containers/storage/";
            };
        };
    };

    # XDG portals
    xdg.portal = {
        enable = true;
        wlr.enable = true;
    };

    # console font
    console = {
        earlySetup = true;
        font = "ter-v24b";
        packages = with pkgs; [
            terminus_font
        ];
    };

    # custom systemd user services
    systemd.user.services = {
        "polkit-kde" = {
            description = "Polkit KDE Authentication Agent";
            unitConfig = {
                Requires = [ "graphical-session.target" ];
                After = [ "graphical-session.target" ];
                PartOf = [ "graphical-session.target" ];
                bindsTo = [ "graphical-session.target" ];
                StartLimitIntervalSec = 240;
                StartLimitBurst = 240;
            };
            serviceConfig = {
                ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
                Restart = "always";
                RestartSec = 1;
            };
            wantedBy = [ "graphical-session.target" ];
        };
        # "udiskie-tray" = {
        #     description = "Udiskie System Tray";
        #     unitConfig = {
        #         Requires = [ "graphical-session.target" ];
        #         After = [ "graphical-session.target" ];
        #         PartOf = [ "graphical-session.target" ];
        #         StartLimitIntervalSec = 240;
        #         StartLimitBurst = 240;
        #     };
        #     serviceConfig = {
        #         ExecCondition = "/bin/sh -c 'systemctl --user show-environment | grep -q -E \"(DISPLAY|WAYLAND_DISPLAY)\"'";
        #         Environment = [
        #             "GI_TYPELIB_PATH=${pkgs.gtk3}/lib/girepository-1.0:${pkgs.libappindicator-gtk3}/lib/girepository-1.0"
        #         ];
        #         ExecStart = "${pkgs.udiskie}/bin/udiskie" + " " + pkgs.lib.escapeShellArgs [
        #             "--notify"
        #             "--no-automount"
        #             "--no-menu-checkbox-workaround"
        #             "--no-menu-update-workaround"
        #             "--no-password-cache"
        #             "--appindicator"
        #             "--file-manager" "${pkgs.kdePackages.dolphin}/bin/dolphin"
        #             "--config" "/etc/udiskie/config.yaml"
        #             "--tray"
        #         ];
        #         Restart = "always";
        #         RestartSec = 1;
        #     };
        #     bindsTo = [ "graphical-session.target" ];
        #     wantedBy = [ "graphical-session.target" ];
        # };
        # "easyeffects-tray" = {
        #     description = "Easyeffects Audio Effects Daemon";
        #     unitConfig = {
        #         Requires = [ "graphical-session.target" ];
        #         After = [ "graphical-session.target" ];
        #         PartOf = [ "graphical-session.target" ];
        #         bindsTo = [ "graphical-session.target" ];
        #         StartLimitIntervalSec = 240;
        #         StartLimitBurst = 240;
        #     };
        #     serviceConfig = {
        #         ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
        #         Restart = "always";
        #         RestartSec = 1;
        #     };
        #     wantedBy = [ "graphical-session.target" ];
        # };
        # "nm-applet-tray" = {
        #     description = "NetworkManager Applet";
        #     unitConfig = {
        #         Requires = [ "graphical-session.target" ];
        #         After = [ "graphical-session.target" ];
        #         PartOf = [ "graphical-session.target" ];
        #         bindsTo = [ "graphical-session.target" ];
        #         StartLimitIntervalSec = 240;
        #         StartLimitBurst = 240;
        #     };
        #     serviceConfig = {
        #         ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
        #         Restart = "always";
        #         RestartSec = 1;
        #     };
        #     wantedBy = [ "graphical-session.target" ];
        #
        # };
        # "mako-notification-daemon" = {
        #     description = "Notification Daemon";
        #     unitConfig = {
        #         Requires = [ "graphical-session.target" ];
        #         After = [ "graphical-session.target" ];
        #         PartOf = [ "graphical-session.target" ];
        #         bindsTo = [ "graphical-session.target" ];
        #         StartLimitIntervalSec = 240;
        #         StartLimitBurst = 240;
        #     };
        #     serviceConfig = {
        #         ExecStart = "${pkgs.mako}/bin/mako" + " " + pkgs.lib.escapeShellArgs [
        #             "--border-size=4"
        #             "--border-radius=8"
        #             "--background-color='#333333'"
        #             "--default-timeout=4000"
        #             "--max-visible=4"
        #         ];
        #         Restart = "on-failure";
        #         RestartSec = 1;
        #     };
        #     wantedBy = [ "graphical-session.target" ];
        #
        # };
        # "playerctld-daemon" = {
        #     description = "Media Player Daemon";
        #     unitConfig = {
        #         Requires = [ "graphical-session.target" ];
        #         After = [ "graphical-session.target" ];
        #         PartOf = [ "graphical-session.target" ];
        #         bindsTo = [ "graphical-session.target" ];
        #         StartLimitIntervalSec = 240;
        #         StartLimitBurst = 240;
        #     };
        #     serviceConfig = {
        #         ExecStart = "${pkgs.playerctl}/bin/playerctld";
        #         Restart = "on-failure";
        #         RestartSec = 1;
        #     };
        #     wantedBy = [ "graphical-session.target" ];
        #
        # };
    };
    environment.etc."udiskie/config.yaml".source = (pkgs.formats.yaml {}).generate "config.yaml" (import ./configs/udiskie.yaml.nix);

    # custom systemd system services
    systemd.services = {
        "nbfc-service" = {
            enable = true;
            description = "nbfc: Notebook fan control";
            documentation = [ "man:nbfc_service(1)" ];
            after = [ "network.target" ];
            unitConfig = {
                StartLimitIntervalSec = 240;
                StartLimitBurst = 240;
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
                StartLimitIntervalSec = 240;
                StartLimitBurst = 240;
            };
            serviceConfig = {
                ExecStart = "/usr/local/bin/ryzenprofiled";
                Restart = "always";
                RestartSec = 1;
            };
            wantedBy = [ "multi-user.target" ];
        };
        "docker".wantedBy = lib.mkForce [];
        "podman".wantedBy = lib.mkForce [];
        "cron".wantedBy = lib.mkForce [];
    };
}

