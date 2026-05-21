{ pkgs, ... }:

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

    # Locale
    time.timeZone = "Asia/Kolkata";
    i18n.defaultLocale = "en_US.UTF-8";

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    boot.kernelPackages = pkgs.linuxPackages_latest;

    system.stateVersion = "25.11";
}

