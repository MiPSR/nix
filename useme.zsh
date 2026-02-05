#!/usr/bin/env zsh

if [[ -z "$ZSH_VERSION" ]]; then
	echo "Error: this script must be run with zsh." >&2
	exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
	echo "Error: running this script as root is not allowed." >&2
	exit 1
fi

clear
echo "Hello $USER !"
sleep 1

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
DOTS_LOCAL_DIR="/home/$USER/.config"
DOTS_REPOSITORY_DIR="$SCRIPT_DIR/$HOST"
NIX_REPOSITORY_DIR="$DOTS_REPOSITORY_DIR/nixos"

dotfiles=()
FILE_COUNT=0

if [[ -f "$DOTS_REPOSITORY_DIR/files.txt" ]]; then
	while IFS= read -r line; do
		[[ -n "$line" ]] && dotfiles+=("$line") && ((FILE_COUNT++))
	done < "$DOTS_REPOSITORY_DIR/files.txt"
fi

deploy() {
	for file in "${dotfiles[@]}"; do
		local source="$DOTS_REPOSITORY_DIR/$file"
		local target="$DOTS_LOCAL_DIR/$file"
		if [[ -f "$source" ]]; then
			mkdir -p "${target:h}"
			cp "$source" "$target"
			sudo chown "$USER:" "$target"
		else
			echo "Error: $source not found" >&2
		fi
	done
}

collect() {
	for file in "${dotfiles[@]}"; do
		local source="$DOTS_LOCAL_DIR/$file"
		local target="$DOTS_REPOSITORY_DIR/$file"
		if [[ -f "$source" ]]; then
			mkdir -p "${target:h}"
			cp "$source" "$target"
		else
			echo "Error: $source not found" >&2
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

						local nix_source="$NIX_REPOSITORY_DIR/configuration.nix"
						local nix_target="/etc/nixos/configuration.nix"

						if [[ -f "$nix_source" ]]; then
							sudo cp "$nix_source" "$nix_target"
							sudo chown root:root "$nix_target"
						else
							echo "Error: $nix_source not found" >&2
						fi

						if (( ${#dotfiles} > 0 )); then deploy; fi

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

				local nix_source="/etc/nixos/configuration.nix"
				local nix_target="$NIX_REPOSITORY_DIR/configuration.nix"

				if [[ -f "$nix_source" ]]; then
					mkdir -p "${nix_target:h}"
					cp "$nix_source" "$nix_target"
				else
					echo "Error: $nix_source not found" >&2
				fi

				if (( ${#dotfiles} > 0 )); then collect; fi

				echo "Done. Press any key."
				read -k1
			;;
    esac
done
