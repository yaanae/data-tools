{ ... }:
{
  perSystem = { pkgs, lib, self', ... }: {
    packages.moppen-mdx07-init = pkgs.writeShellApplication {
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
            get_template_extends "${self'.packages.moppen-mdx07-templates}/Basic templates/$extendsTemplate"
            printf "%s\n" "${self'.packages.moppen-mdx07-templates}/Basic templates/$extendsTemplate" >&1
          fi
          return 0
        }


        printf "OK, let's go!\n"
        printf "\n"

        printf "This will create files in the current directory, and could\n"
        printf "possibly override your personal files.\n"
        printf "Do with that information what you wish\n"
        printf "\n"

        templatePath=$(get_template_recursive "${self'.packages.moppen-mdx07-templates}")

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
  };
}

