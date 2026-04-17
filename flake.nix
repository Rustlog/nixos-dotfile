{
    description = "System configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    outputs = { nixpkgs, ... }:
        let
            hostname = "nixos-btw";
            system = "x86_64-linux";
            laptop = nixpkgs.lib.nixosSystem {
                system = "${system}";
                specialArgs = { inherit hostname; };
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

