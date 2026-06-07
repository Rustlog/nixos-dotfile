{
    description = "System configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        waterfox.url = "github:Hythera/nix-waterfox";
        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { ... }@inputs:
        let
            system = "x86_64-linux";
            stable = inputs.nixpkgs;
            hostname = "nixos-btw";
            zen-browser = inputs.zen-browser;
            waterfox = inputs.waterfox;
            unstable-pkgs = import inputs.nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
            };
            perserve_inputs = {
                # system.extraDependencies = builtins.attrValues inputs;
                system.extraDependencies =
                let
                    collectFlakeInputs =  input: [ input ] ++
                        builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or {}));
                in
                    builtins.concatMap collectFlakeInputs (builtins.attrValues inputs);
            };
            nixos = stable.lib.nixosSystem {
                inherit system;
                specialArgs = {
                    inherit hostname;
                    inherit unstable-pkgs;
                    inherit zen-browser waterfox;
                };
                modules = [
                    ./hosts/nixos/configuration.nix
                    perserve_inputs
                ];
            };
        in {
            nixosConfigurations = {
                ${hostname} = nixos;
            };
        };
}

