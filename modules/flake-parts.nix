{ inputs, lib, ... }:
{
  systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
  
  imports = [ inputs.flake-parts.flakeModules.modules ];
  
  flake.modules.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
  };
  
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  };
}

