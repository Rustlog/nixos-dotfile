{ pkgs, ... }:

{
    # users
    users.users = {
        "rustlog" = {
            enable = true;
            uid = 1000;
            description = "Rustlog (rustlog)";
            isNormalUser = true;
            shell = pkgs.bashInteractive;
            group = "rustlog";
            extraGroups = [
                "wheel" "audio" "input" "disk" "kvm"
                "kmem" "wireshark" "networkmanager"
                "video" "storage" "root"
            ];
        };
        "self" = {
            enable = true;
            name = "self";
            uid = 1001;
            description = "Self (admin)";
            isNormalUser = true;
            shell = pkgs.bashInteractive;
            group = "self";
            extraGroups = [
                "wheel" "audio" "input" "disk"
                "kvm" "kmem" "networkmanager"
                "video" "storage" "root"
            ];
        };
        "guest" = {
            enable = true;
            uid = 1002;
            description = "Guest (guest)";
            isNormalUser = true;
            password = "guest";
            createHome = true;
            shell = pkgs.bashInteractive;
            group = "guest";
            extraGroups = [
                "audio" "video"
            ];
        };
        "dojo" = {
            enable = true;
            uid = 1003;
            description = "Dojo (dojo)";
            isNormalUser = true;
            password = "dojo";
            createHome = true;
            shell = pkgs.bashInteractive;
            group = "dojo";
            extraGroups = [
                "audio" "video"
            ];
        };
    };

    # groups
    users.groups = {
        "rustlog" = { gid = 1000; };
        "self" = { gid = 1001; };
        "guest" = { gid = 1002; };
        "dojo" = { gid = 1003; };
    };
}

