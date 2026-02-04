#!/usr/bin/env zsh

if [[ "$EUID" -eq 0 ]]; then
    echo "Error: running this script as root is not allowed."
    exit 1
fi

clear
echo "Hello $USER !"
sleep 1

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
NIXOS_SCRIPT_CONFIG_DIR="$SCRIPT_DIR/$HOST/nixos"
DOTS_SCRIPT_CONFIG_DIR="$SCRIPT_DIR/$HOST/"

declare -a files=()

FILE_COUNT=0

if [[ -f "$DOTS_SCRIPT_CONFIG_DIR/files.txt" ]]; then
  while IFS=: read -r filename system_path; do
    [[ -z $filename || -z $system_path ]] && continue
    files+=("$filename:$system_path")
    FILE_COUNT=$((FILE_COUNT + 1))
  done < "$DOTS_SCRIPT_CONFIG_DIR/files.txt"
fi

deploy() {
  for f in "${files[@]}"; do
    filename=${f%%:*}
    system_path=${f##*:}
    echo "Copying $filename → $system_path"
    if [[ -f "$DOTS_SCRIPT_CONFIG_DIR/$filename" ]]; then
        mkdir -p "$(dirname "$system_path")"
        cp "$DOTS_SCRIPT_CONFIG_DIR/$filename" "$system_path"
        chown $USER: "$system_path"
    else
        echo "Error: $DOTS_SCRIPT_CONFIG_DIR/$filename not found"
    fi
  done
}

collect() {
  for f in "${files[@]}"; do
    filename=${f%%:*}
    system_path=${f##*:}
    echo "Copying $system_path → $DOTS_SCRIPT_CONFIG_DIR/$filename"
    if [[ -f "$system_path" ]]; then
        mkdir -p "$(dirname "$DOTS_SCRIPT_CONFIG_DIR/$filename")"
        cp "$system_path" "$DOTS_SCRIPT_CONFIG_DIR/$filename"
        chown $USER: "$DOTS_SCRIPT_CONFIG_DIR/$filename"
    else
        echo "Error: $system_path not found"
    fi
  done
}

while true; do
    clear
    echo "# NixOS sync script #"
    if (( FILE_COUNT < 2 )); then
        echo "Current system: $HOST [$FILE_COUNT file available]"
    else
        echo "Current system: $HOST [$FILE_COUNT files available]"
    fi
    echo "Current user: $USER"

    lines=$(tput lines)
    tput cup $((lines - 2)) 0

    local width=$COLUMNS
    printf '%*s\n' "$width" '' | tr ' ' '#'

    echo -n "Action: [s] system -> git | [l] git -> system | [q] quit "
    read -k1 action

    case $action in
        l)
            clear
            echo -n "This is going to replace your existing configuration.nix, are you sure ? (y/n) "
            while true; do
                read -k1 choice
                case $choice in
                    y)
                        echo "Loading..."

                        if [[ -f "$NIXOS_SCRIPT_CONFIG_DIR/configuration.nix" ]]; then
                            sudo cp "$NIXOS_SCRIPT_CONFIG_DIR/configuration.nix" "/etc/nixos/configuration.nix"
                            sudo chown root:root "/etc/nixos/configuration.nix"
                        else
                            echo "Error: $NIXOS_SCRIPT_CONFIG_DIR/configuration.nix not found"
                        fi

                        deploy

                        echo "Done. Press any key."
                        read -k1
                        break
                    ;;
                    n)
                        break
                    ;;
                esac
            done
        ;;
        q)
            clear
            echo "Goodbye $USER !"
            sleep 1
            clear
            exit
        ;;
        s)
            clear
            echo "Saving..."
            mkdir -p "$NIXOS_SCRIPT_CONFIG_DIR"

            if [[ -f "/etc/nixos/configuration.nix" ]]; then
                sudo cp "/etc/nixos/configuration.nix" "$NIXOS_SCRIPT_CONFIG_DIR/configuration.nix"
                sudo chown $USER: "$NIXOS_SCRIPT_CONFIG_DIR/configuration.nix"
            else
                echo "Error: /etc/nixos/configuration.nix not found"
            fi

            collect

            echo "Done. Press any key."
            read -k1
        ;;
    esac
done
