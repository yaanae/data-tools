{ ... }:
{
  perSystem = { pkgs, self', ... }: {
    devShells.moppen-eda482 = pkgs.mkShell {
      packages = with self'.packages; [
        pkgs.gnumake
        pkgs.gdb
        moppen-mdx07-gcc
        moppen-mdx07-binaries-openocd
        moppen-mdx07-binaries-rv32emu
        moppen-mdx07-init
        moppen-neovim
      ];
    };
    devShells.moppen = self'.devShells.moppen-eda482;
  };
}
