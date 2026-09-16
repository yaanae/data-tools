{ inputs, self, ... }:
{
  perSystem = { pkgs, lib, ... }: {
    packages.moppen-mdx07-binaries-openocd = let
      arch-string = ipkgs: with ipkgs.stdenv.hostPlatform;
        if isLinux && isx86_64 then
          "linux-x64"
        else if isDarwin && isx86_64 then
          "macos-x64"
        else if isDarwin && isAarch64 then
          "macos-arm64/bin"
        else
          throw "Could not find a binary for the specified platform";
    in pkgs.stdenv.mkDerivation {
      name = "mdx07-binaries-openocd";
      src = inputs.mdx07-binaries;
      nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
      buildInputs = with pkgs; [ libusb1 ];
      patchPhase = ''
        chmod -x linux-x64/openocd.cfg
      '';
      installPhase = ''
        mkdir -p $out/bin
        cp $src/${arch-string pkgs}/openocd $out/bin/openocd
        cp $src/${arch-string pkgs}/openocd.cfg $out/bin/openocd.cfg
      '';
      meta = {
        description = "Binary tools for MDx07";
        homepage = "https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
        license = lib.licenses.unfree;
        platforms = [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
      };
    };
  };
}
