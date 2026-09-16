{
  description = "Verktyg för studenter på Chalmers Datateknologsektion";

  # I really wish we could modularize the inputs, just as separate files with attrsets,
  # noting too fancy, but it seems we won't be doing that. Ugh.
  inputs = {
    #--------- Top level --------#
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    #------ moppen-eda482 -------#
    mdx07-templates = {
      url = "git+https://git.chalmers.se/haelias/mdx07-templates-library.git";
      flake = false;
    };
    mdx07-binaries = {
      url = "git+https://git.chalmers.se/erik.sintorn/mdx07-binaries.git";
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

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
      { inherit inputs; }
      (inputs.import-tree ./modules);
}

