# { lib, ... }:
{
    # nix.gc = {
    #     automatic = true;
    #     options = "--delete-older-than 20d";
    # };
    # systemd.units."nix-gc.timer".text = lib.mkForce ''
    #     [Unit]
    #     Description=Nix garbage collection
    #
    #     [Timer]
    #     OnBootSec=10m
    #     OnUnitActiveSec=1d
    #     Persistent=true
    #     RandomizedDelaySec=0
    #
    #     [Install]
    #     WantedBy=timers.target
    # '';
}

