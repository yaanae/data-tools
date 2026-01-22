{ inputs, system }:
let
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  templates = pkgs.stdenv.mkDerivation {
    name = "mdx07-templates";
    src = inputs.mdx07-templates;
    unpackPhase = ''
      mkdir -p $out
      cp -r --no-preserve=all $src/templates/* $out

      cp ${pkgs.writeText ".asm-lsp.toml" ''
        [default_config]
        version = "0.10.1"
        assembler = "gas"
        instruction_set = "riscv"

        [opts]
        compiler = "riscv32-unknown-elf-gcc"
        diagnostics = true
        default_diagnostics = true
      ''} "$out/Basic templates/md307-master/.asm-lsp.toml"

      cp ${pkgs.writeText "compile-flags.txt" ''
        -g -Wall -Wextra -std=c99 -MMD -march=rv32imf_zicsr -mabi=ilp32f
      ''} "$out/Basic templates/md307-master/compile_flags.txt"
    '';
  };
  mdx07-init = pkgs.writeShellApplication {
    name = "mdx07-init";
    text = ''
      select_menu() {
        local prompt="$1"
        shift
        local options=("$@")
        local choice

        if [ "''${#options[@]}" -eq 0 ]; then
          echo "No options provided." >&2
          return 1
        fi

        echo "$prompt" >&2
        for i in "''${!options[@]}"; do
          printf "  %d) %s\n" "$((i+1))" "''${options[i]}" >&2
        done

        printf "Select [1-%d]: " "''${#options[@]}" >&2
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ''${#options[@]} )); then
          printf "\n" >&2
          printf '%s\n' "''${options[choice-1]}" >&1
          return 0
        fi

        return 1
      }

      # Recursively decend the directories in the templates-zip,
      # checking for "template.json" to know we have reached the
      # end.
      get_template_recursive() {
        local directory="$1"
        mapfile -t templates < <(find "$directory" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort)
        local template
        template=$(select_menu "Select a template:" "''${templates[@]}")
        local templatePath="$directory/$template"

        if [[ ! -f "$templatePath/template.json" ]]; then
          get_template_recursive "$templatePath"
        else
          printf "%s\n" "$templatePath" >&1
        fi
        return 0
      }

      # Templates can extends other templates. Why?!!!
      # No matter, we just have to recursively check it.
      get_template_extends() {
        local templatePath="$1"
        local extendsTemplate
        extendsTemplate=$( cat "$templatePath/template.json" | ${pkgs.jq}/bin/jq -r ".extends" )
        
        if [[ "$extendsTemplate" != "null" ]]; then
          get_template_extends "${templates}/Basic templates/$extendsTemplate"
          printf "%s\n" "${templates}/Basic templates/$extendsTemplate" >&1
        fi
        return 0
      }


      printf "OK, let's go!\n"
      printf "\n"

      printf "This will create files in the current directory, and could\n"
      printf "possibly override your personal files.\n"
      printf "Do with that information what you wish\n"
      printf "\n"

      templatePath=$(get_template_recursive "${templates}")

      mapfile -t templateExtendsList < <(get_template_extends "$templatePath" && printf "%s\n" "$templatePath")

      for i in "''${templateExtendsList[@]}"; do
        cp --no-preserve=all -r "$i/." .
      done

      rm template.json

    '';
  };
  riscv-gcc = pkgs.stdenv.mkDerivation {
    name = "riscv-gcc";
    src = inputs.riscv-gcc;
    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    buildInputs = with pkgs; [ stdenv.cc.cc.lib zlib expat ncurses ];
    sourceRoot = ".";
    installPhase = ''
      ls -la .
      ls -la $src
      mkdir -p $out
      cd source
      # Remove broken symlinks
      rm bin/clang bin/clang++ bin/riscv32-unknown-elf-clang++ bin/clang-cpp bin/riscv32-unknown-elf-clang bin/clang-cl
      # Move to output, skipping weird MacOS files, .DS_Store, etc.
      cp -r bin include lib libexec riscv32-unknown-elf share $out/
    '';
    dontCheckForBrokenSymlinks = true;
  };
  mdx07-binaries = pkgs.stdenv.mkDerivation {
    name = "simserver";
    src = inputs.mdx07-binaries;
    nativeBuildInputs = with pkgs; [ unzip autoPatchelfHook wrapGAppsHook3 ];
    buildInputs = with pkgs; [
      libusb1
      xorg.libXxf86vm
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp --dereference -r $src/linux-x64/* $out/bin/
    '';
  };

  neovim = inputs.nixvim.legacyPackages."x86_64-linux".makeNixvimWithModule {
    system = "x86_64-linux";
    module = import ./neovim.nix;
    extraSpecialArgs = { actions-nvim = inputs.actions-nvim; };
  };

in
rec {
  packages.${system} = {
    "moppen-mdx07-binaries" = mdx07-binaries;
    "moppen-mdx07-init" = mdx07-init;
    "moppen-riscv-gcc" = riscv-gcc;
    "moppen-neovim" = neovim;
  };

  devShells.${system} = {
    "moppen-eda482" = pkgs.mkShell {
      packages = [
        pkgs.gnumake
        pkgs.gdb
        riscv-gcc
        mdx07-init
        mdx07-binaries
        neovim
      ];
    };
    "moppen" = devShells.${system}."moppen-eda482";
  };
}
