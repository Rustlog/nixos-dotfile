{ hostname, ... }:

{
    # system networking
    networking = {
        networkmanager.enable = true;
        hostName = hostname;
        nat.enable = false;
        nameservers = [ "127.0.0.1" "8.8.8.8" ];
        firewall = {
            enable = true;
            allowedTCPPorts = [
                22 53 443
                8096 # jellyfin
                1716 # kdeconnect
            ];
            allowedUDPPorts = [ 53 ];
        };
    };
}

