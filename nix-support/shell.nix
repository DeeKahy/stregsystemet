{pkgs ? import <nixpkgs> {}, ...}:

let
    deps = import ./dependencies.nix { inherit pkgs; };
    pythonEnv = pkgs.python311.withPackages deps;
in pkgs.mkShell {
    packages = [ pythonEnv pkgs.mailhog pkgs.black ];
}
