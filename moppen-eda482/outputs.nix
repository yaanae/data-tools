{ inputs, ... }:
{
  perSystem = { pkgs, lib, system, self', ... }: let

    mdx07-templates = pkgs.stdenvNoCC.mkDerivation {
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
      meta = {
        description = "Project templates for MDx07";
        homepage = "https://git.chalmers.se/haelias/mdx07-templates-library.git";
        license = lib.licenses.unfree;
        platforms = lib.platforms.all;
      };
    };

    mdx07-init = pkgs.writeShellApplication {
      name = "mdx07-init";
      runtimeInputs = with pkgs; [ jq findutils coreutils ];
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
            get_template_extends "${mdx07-templates}/Basic templates/$extendsTemplate"
            printf "%s\n" "${mdx07-templates}/Basic templates/$extendsTemplate" >&1
          fi
          return 0
        }


        printf "OK, let's go!\n"
        printf "\n"

        printf "This will create files in the current directory, and could\n"
        printf "possibly override your personal files.\n"
        printf "Do with that information what you wish\n"
        printf "\n"

        templatePath=$(get_template_recursive "${mdx07-templates}")

        mapfile -t templateExtendsList < <(get_template_extends "$templatePath" && printf "%s\n" "$templatePath")

        for i in "''${templateExtendsList[@]}"; do
          cp --no-preserve=all -r "$i/." .
        done

        rm template.json

      '';
      meta = {
        description = "Script to initialize templates for mdx07";
        homepage = "https://github.com/yaanae/data-tools/moppen-eda487";
        license = lib.licenses.lgpl3;
        platforms = lib.platforms.all;
      };

    };

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

    mdx07-binary-riscv-gcc = pkgs.stdenv.mkDerivation {
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
      meta = {
        description = "RISC-V GCC toolchain for MD307";
        homepage = "https://www.cse.chalmers.se/edu/resources/software/riscv32-gcc";
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
      };
    };
    
    mdx07-binaries = pkgs.stdenv.mkDerivation {
      name = "mdx07-binaries";
      src = inputs.mdx07-binaries;
      nativeBuildInputs = with pkgs; [ unzip autoPatchelfHook wrapGAppsHook3 ];
      buildInputs = with pkgs; [
        libusb1
        xorg.libXxf86vm
      ];
      patchPhase = ''
        chmod -x linux-x64/openocd.cfg
        chmod +x linux-x64/make
      '';
      installPhase = let
        arch =
          with pkgs.stdenv.hostPlatform;
          if isLinux && isx86_64 then
            "linux-x64"
          else if isDarwin && isx86_64 then
            "macos-x64"
          else if isDarwin && isAarch64 then
            "macos-arm64"
          else
            throw "Could not find a binary for the specified platform";
      in ''
        mkdir -p $out
        cp --dereference -r $src/${arch}/ $out/bin
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
    
    neovim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
      system = "x86_64-linux";
      module = import ./neovim.nix;
      extraSpecialArgs = { actions-nvim = inputs.actions-nvim; };
    };

  in {
    packages = {
      moppen-mdx07-init = mdx07-init;
      moppen-mdx07-gcc = riscv32-embedded-pkgs.gcc;
      moppen-mdx07-gcc-bin = mdx07-binary-riscv-gcc;
      moppen-mdx07-binaries = mdx07-binaries;
      moppen-neovim = neovim;
    };

    devShells = {
      moppen-eda482 = pkgs.mkShell {
        packages = with self'.packages; [
          pkgs.gnumake
          pkgs.gdb
          moppen-mdx07-gcc-bin
          moppen-mdx07-binaries
          moppen-mdx07-init
          moppen-neovim
        ];
      };
      moppen = self'.devShells.moppen-eda482;
    };
  };
}
