{ pkgs, ... }:

{
    # users
    users.users = {
        "self" = {
            enable = true;
            name = "self";
            uid = 1000;
            description = "(admin)";
            isNormalUser = true;
            shell = pkgs.bashInteractive;
            group = "self";
            extraGroups = [
                "wheel" "audio" "input" "disk" "kvm"
                "kmem" "wireshark" "networkmanager"
                "video" "storage" "root"
            ];
        };
        "guest" = {
            enable = true;
            name = "guest";
            uid = 1001;
            description = "(guest)";
            isNormalUser = true;
            password = "guest";
            createHome = true;
            shell = pkgs.bashInteractive;
            group = "guest";
            extraGroups = [
                "audio" "video"
            ];
        };
    };

    # groups
    users.groups = {
        "self" = {
            gid = 1000;
        };
        "guest" = {
            gid = 1001;
        };
    };
}

