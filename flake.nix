{
    description = "System configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        zen-browser.url = "github:youwen5/zen-browser-flake";
    };

    outputs = { nixpkgs, ... }@args:
        let
            hostname = "nixos-btw";
            zen-browser = args.zen-browser;
            system = "x86_64-linux";
            laptop = nixpkgs.lib.nixosSystem {
                system = "${system}";
                specialArgs = { inherit hostname; inherit zen-browser; };
                modules = [
                    ./hosts/laptop/configuration.nix
                ];
            };
        in {
            nixosConfigurations = {
                ${hostname} = laptop;
            };
        };
}

