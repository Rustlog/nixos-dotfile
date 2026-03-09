{ config, pkgs, lib, ... }:

{
    # users config
    users.users = { 
        "self" = {
            isNormalUser = true;
            shell = pkgs.bash;
            extraGroups = [
                "wheel" "audio" "input" "rtkit"
                "disk" "kmem" "networkmanager" "video"
                "storage" "kvm" "root"
            ];
        };
    };
}

