{ config, lib, pkgs, ... }:

{
    imports = [
        ./modules/environment.nix
        ./modules/networking.nix
        ./modules/packages.nix
        ./modules/services.nix
        ./modules/hardware.nix
        ./modules/tweaks.nix
        ./modules/users.nix
        ./modules/nix.nix
    ];

    # Programs
    programs = {
        sway.enable = true;
        git.enable = true;
        bash.enable = true;
        zsh.enable = true;
        nix-ld.enable = true;
    };

    # XDG portals
    xdg.portal = {
        enable = true;
        wlr.enable = true;
    };

    # Locale
    time.timeZone = "Asia/Kolkata";
    i18n.defaultLocale = "en_US.UTF-8";

    console = {
        packages = with pkgs; [
            terminus_font
        ];
    };

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.kernelPackages = pkgs.linuxPackages_latest;

    system.stateVersion = "25.11";
}

