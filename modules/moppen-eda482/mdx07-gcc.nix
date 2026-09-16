{ inputs, ... }:
{
  perSystem = { pkgs, system, self', ... }: {
    packages.moppen-mdx07-gcc-noncompat = let
      riscv32-embedded-pkgs = import inputs.nixpkgs {
        inherit system;
        crossSystem = {
          config = "riscv32-none-elf";
          libc = "newlib-nano";
          gcc = {
            arch = "rv32imf_zicsr";
            abi = "ilp32f";
          };
        };
      };
    in riscv32-embedded-pkgs.buildPackages.gcc;

    packages.moppen-mdx07-gcc = pkgs.runCommand
      "riscv32-embedded-gcc-compat"
      { nativeBuildInputs = [ self'.packages.moppen-mdx07-gcc-noncompat ]; }
      ''
        mkdir -p $out/bin
        ls -1 ${self'.packages.moppen-mdx07-gcc-noncompat}/bin | cut -d "-" -f 4- | xargs -I {} ln -s ${self'.packages.moppen-mdx07-gcc-noncompat}/bin/riscv32-none-elf-{} $out/bin/riscv32-unknown-elf-{}
      '';
  };
}

