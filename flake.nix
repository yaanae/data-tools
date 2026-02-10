{
  description = "Verktyg för studenter på Chalmers Datateknologsektion";

  # I really wish we could modularize the inputs, just as separate files with attrsets,
  # noting too fancy, but it seems we won't be doing that. Ugh.
  inputs = {
    #--------- Top level --------#
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    #------ moppen-eda482 -------#
    mdx07-templates = {
      url = "git+https://git.chalmers.se/haelias/mdx07-templates-library.git";
      flake = false;
    };
    mdx07-binaries = {
      url = "git+https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
      flake = false;
    };
    riscv-gcc = {
      url = "https://www.cse.chalmers.se/edu/resources/software/riscv32-gcc/riscv-gcc-ubuntu-22.04-x64.tar.gz";
      flake = false;
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    actions-nvim = {
      url = "github:yaanae/actions.nvim";
      flake = false;
    };
  };

  outputs = { flake-parts, ...}@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }@top: 
      { systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ]; }
      // (import ./moppen-eda482/outputs.nix top)
    );
}

