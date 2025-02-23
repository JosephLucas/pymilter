{
  description = "A python extension module to enable python scripts to attach to Sendmail's libmilter API, enabling filtering of messages as they arrive";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in {
      overlay = final: prev: { pymilter = (import ./default.nix { pkgs = final; }); };
      # FIXME: would be cool to modify pythonPackages
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) pymilter; });
      defaultPackage = forAllSystems (system: self.packages.${system}.pymilter);
      # FIXME: check also for x86_64-darwin as soon as Hydra will check darwin derivations
      checks.x86_64-linux.pymilter = self.packages.x86_64-linux.pymilter;
      # FIXME: why can I import Milter (the pymilter module) in a the python interpreter of the dev shell
      devShell = forAllSystems (system: self.packages.${system}.pymilter.override { inShell = true; });
    };
}
