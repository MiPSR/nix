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

                        if [[ -f "$NIXOS_SCRIPT_CONFIG_DIR/configuration.nix" ]]; then
                            sudo cp "$NIXOS_SCRIPT_CONFIG_DIR/configuration.nix" "/etc/nixos/configuration.nix"
                            sudo chown root:root "/etc/nixos/configuration.nix"
                        else
                            echo "Error: $NIXOS_SCRIPT_CONFIG_DIR/configuration.nix not found"
                        fi

                        case $HOST in
                            "fuuka")
                                i3_dir="$HOME/.config/i3/"
                                i3status_dir="$HOME/.config/i3status_rust/"

                                if [[ -f "$DOTS_SCRIPT_CONFIG_DIR/i3/config" ]]; then
                                    cp "$DOTS_SCRIPT_CONFIG_DIR/i3/config" "$i3_dir/config"
                                else
                                    echo "Error: $DOTS_SCRIPT_CONFIG_DIR/i3/config not found"
                                fi

                                if [[ -f "$DOTS_SCRIPT_CONFIG_DIR/i3status-rust/config.toml" ]]; then
                                    cp "$DOTS_SCRIPT_CONFIG_DIR/i3status-rust/config.toml" "$i3status_dir/config"
                                else
                                    echo "Error: $DOTS_SCRIPT_CONFIG_DIR/i3status-rust/config.toml not found"
                                fi
                            ;;
                        esac

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

            case $HOST in
                "fuuka")
                    i3_dir="$HOME/.config/i3/"
                    i3status_dir="$HOME/.config/i3status_rust/"

                    if [[ -f "$i3_dir/config" ]]; then
                        cp "$i3_dir/config" "$DOTS_SCRIPT_CONFIG_DIR/i3/config"
                    else
                        echo "Error: $i3_dir/config not found"
                    fi

                    if [[ -f "$i3status_dir/config" ]]; then
                        cp "$i3status_dir/config" "$DOTS_SCRIPT_CONFIG_DIR/i3status-rust/config.toml"
                    else
                        echo "Error: $i3status_dir/config.toml not found"
                    fi
                ;;
            esac

            echo "Done. Press any key."
            read -k1
        ;;
    esac
done
