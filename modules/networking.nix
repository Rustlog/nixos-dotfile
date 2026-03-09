{ config, ... }:

{
    # system networking
    networking = {
        networkmanager.enable = true;
        hostName = "nixos";
        nat.enable = false;
        nameservers = [ "127.0.0.1" ];
        firewall = {
            enable = true;
            allowedTCPPorts = [ 22 53 443 ];
            allowedUDPPorts = [ 53 ];
        };
    };
}

