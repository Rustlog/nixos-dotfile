{
    description = "System configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        zen-browser = {
            url = "github:youwen5/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
    };

    outputs = { ... }@inputs:
        let
            system = "x86_64-linux";
            stable = inputs.nixpkgs;
            hostname = "nixos-btw";
            zen-browser = inputs.zen-browser;
            unstable-pkgs = import inputs.nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
            };
            laptop = stable.lib.nixosSystem {
                inherit system;
                specialArgs = {
                    inherit hostname;
                    inherit zen-browser;
                    inherit unstable-pkgs;
                };
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

