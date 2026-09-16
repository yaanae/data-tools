{ inputs, ... }:
{
  perSystem = { pkgs, lib, ... }: {
    packages.moppen-mdx07-templates = pkgs.stdenvNoCC.mkDerivation {
      name = "mdx07-templates";
      src = inputs.mdx07-templates;
      unpackPhase = ''
        mkdir -p $out
        cp -r --no-preserve=all $src/templates/* $out
      '';
      meta = {
        description = "Project templates for MDx07";
        homepage = "https://git.chalmers.se/haelias/mdx07-templates-library.git";
        license = lib.licenses.unfree;
        platforms = lib.platforms.all;
      };
    };
  };
}
