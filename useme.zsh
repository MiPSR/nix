#!/usr/bin/env zsh

if [[ "$EUID" -eq 0 ]]; then
    echo "Error: running this script as root is not allowed."
    exit 1
fi

clear
echo "Hello $USER !"
sleep 1

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
CONFIG_DIR="$SCRIPT_DIR/$HOST/nixos"

while true; do
    clear
    echo "# NixOS sync script #"
    echo "Current system: $HOST"
    echo "Current user: $USER"

    lines=$(tput lines)
    tput cup $((lines - 2)) 0

    local width=$COLUMNS
    printf '%*s\n' "$width" '' | tr ' ' '#'

    echo -n "action? Action: [s] system -> git | [l] git -> system | [q] quit "
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

                        if [[ -f "$CONFIG_DIR/configuration.nix" ]]; then
                            sudo cp "$CONFIG_DIR/configuration.nix" "/etc/nixos/configuration.nix"
                            sudo chown root:root "/etc/nixos/configuration.nix"
                        else
                            echo "Error: $CONFIG_DIR/configuration.nix not found"
                        fi

                        if [[ -f "$CONFIG_DIR/hardware-configuration.nix" ]]; then
                            sudo cp "$CONFIG_DIR/hardware-configuration.nix" "/etc/nixos/hardware-configuration.nix"
                            sudo chown root:root "/etc/nixos/hardware-configuration.nix"
                        else
                            echo "Error: $CONFIG_DIR/hardware-configuration.nix not found"
                        fi
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
            mkdir -p "$CONFIG_DIR"

            if [[ -f "/etc/nixos/configuration.nix" ]]; then
                sudo cp "/etc/nixos/configuration.nix" "$CONFIG_DIR/configuration.nix"
                sudo chown $USER: "$CONFIG_DIR/configuration.nix"
            else
                echo "Error: /etc/nixos/configuration.nix not found"
            fi

            if [[ -f "/etc/nixos/hardware-configuration.nix" ]]; then
                sudo cp "/etc/nixos/hardware-configuration.nix" "$CONFIG_DIR/hardware-configuration.nix"
                sudo chown $USER: "$CONFIG_DIR/hardware-configuration.nix"
            else
                echo "Error: /etc/nixos/hardware-configuration.nix not found"
            fi

            echo "Done. Press any key."
            read -k1
        ;;
    esac
done
