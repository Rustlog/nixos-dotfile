{
    description = "System configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    outputs = { nixpkgs, ... }@inputs:
        let
            system = "x86_64-linux";
            laptop = "laptop";
            desktop = "desktop";
            default_HOST = laptop;
        in {
            nixosConfigurations."${default_HOST}" = nixpkgs.lib.nixosSystem {
                system = "${system}";
                modules = [
                    ./hosts/${default_HOST}/configuration.nix
                ];
            };
        };
}

