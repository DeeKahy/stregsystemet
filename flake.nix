{
    description = "F-klubbens Stregsystem";

    # define nixpkgs version to use
    inputs = {
        nixpkgs.url = "nixpkgs/nixos-24.11";
    };

    outputs = { self, nixpkgs }: let 
        linuxSystem = "x86_64-linux";
        linuxPkgs = import nixpkgs { system = linuxSystem; };
        supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
        forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
        # Define the shell for all supported systems
        devShells = forAllSystems (system: let
            pkgs = import nixpkgs { inherit system; };
        in {
            default = import ./nix-support/shell.nix { inherit pkgs; };
        });

        # Default package for the stregsystem (Linux only)
        packages.${linuxSystem} = {
            default = import ./nix-support { pkgs = linuxPkgs; };

            # Test VM
            vm = (nixpkgs.lib.nixosSystem {
                system = linuxSystem;
                modules = [
                    self.nixosModules.default
                    {
                        users.users.root.password = "root";
                        networking.hostName = "fklub";
                        system.stateVersion = "24.05";
                        stregsystemet = {
                            enable = true;
                            port = 80;
                            testData = {
                                enable = true;
                            };
                        };
                    }
                ];
            }).config.system.build.vm;
        };

        # NixOS system modules
        nixosModules.default = import ./nix-support/module.nix;
    };
}
