{ config, pkgs, lib, ... }:

{
    # services module
    services = {
        displayManager = {
            ly.enable = true;
            ly.settings = {
                animation = "colormix";
            };
        };
        tlp.enable = true;
        libinput.enable = true;
        xserver.enable = false;
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
            enable = false;
            daemon.settings = {
                data-root = "/dt/containers/docker_containers/";
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
            serviceConfig = {
                ExecStart = "${pkgs.nbfc-linux}/bin/nbfc_service --config-file /var/nbfc/nbfc.json";
                Restart = "always";
                RestartSec = 3;
            };
            wantedBy = [ "multi-user.target" ];
        };
    };
}

