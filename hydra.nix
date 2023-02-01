{ inputs, outputs }:
let
  inherit (inputs.nixpkgs.lib) filterAttrs mapAttrs elem;

  notBroken = pkg: !(pkg.meta.broken or false);
  hasPlatform = sys: pkg: elem sys pkg.meta.platforms;
  filterValidPkgs = sys: pkgs: filterAttrs (_: pkg: hasPlatform sys pkg && notBroken pkg);
  getCfg = _: cfg: cfg.config.system.build.build.toplevel;
in {
  packages = mapAttrs filterValidPkgs outputs.packages;
  nixos = mapAttrs getCfg outputs.nixosConfigurations;
}