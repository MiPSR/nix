#!/usr/bin/env zsh

if [[ -z "$ZSH_VERSION" ]]; then
	print -u2 "Error: this script must be run with zsh."
	exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
	print -u2 "Error: running this script as root is not allowed."
	exit 1
fi

typeset -ga DOT_FILES=()
typeset -ga NIXOS_FILES=()
typeset -ga NIXOS_COMMON_FILES=()
typeset -gi FILE_COUNT=0

init() {
	local -r repository_dir="$1"
	local -r file="$repository_dir/files.txt"

	if [[ ! -f "$file" ]]; then
		print -u2 "Error: "$file" not found."
		exit 1
	fi

	local current_category=""
	local line

	while IFS= read -r line; do
		[[ -z "$line" ]] && continue

		if [[ "$line" == @* ]]; then
			current_category="${line#@}"
			continue
		fi

		(( FILE_COUNT++ ))

		case "$current_category" in
			dot)					DOT_FILES+=("$line") ;;
			nixos)				NIXOS_FILES+=("$line") ;;
			nixos_common)	NIXOS_COMMON_FILES+=("$line") ;;
			*)						print -u2 "Error: $current_category is incorrect" && exit 1
		esac
	done < $file
}

move_files() {
	local -r array_name="$1"
	local -r source_dir="$2"
	local -r target_dir="$3"
	local -r use_sudo="$4"

	local files_array=()

	case $array_name in
		"dot")
        files_array=("${DOT_FILES[@]}")
    ;;
    "nixos")
        files_array=("${NIXOS_FILES[@]}")
    ;;
    "nixos_common")
        files_array=("${NIXOS_COMMON_FILES[@]}")
    ;;
		*)
			print -u2 "Error: $current_category is incorrect" && exit 1
			exit 1
		;;
	esac

	for file in $files_array; do
		if [[ -f "$source_dir/$file" ]]; then
			if [[ "$use_sudo" == "sudo" ]]; then
				sudo mkdir -p "${target_dir}/${file:h}"
				sudo cp "$source_dir/$file" "$target_dir/$file"
				sudo chown root:root "$target_dir/$file"
			else
				mkdir -p "${target_dir}/${file:h}"
				cp "$source_dir/$file" "$target_dir/$file"
			fi
			print "Copied $source_dir/$file to $target_dir/$file"
		else
			print -u2 "$source_dir/$file not found."
		fi
	done
}

run() {
	local -r script_dir="${0:A:h}"

	local -r dots_local_dir="/home/$USER/.config"
	local -r dots_repository_dir="$script_dir/$HOST"
	local -r nix_local_dir="/etc/nixos"
	local -r nix_repository_dir="$script_dir/$HOST/nixos"
	local -r nix_common_repository_dir="$script_dir/common/nixos"

	init "$dots_repository_dir"

	while true; do
		clear
		print "# NixOS sync script #"
		if (( FILE_COUNT < 2 )); then
			print "Current system: $HOST [$FILE_COUNT file available]"
		else
			print "Current system: $HOST [$FILE_COUNT files available]"
		fi

		print "Current user: $USER"

		local width=$COLUMNS

		printf '%*s\n' "$width" '' | tr ' ' '#'

		lines=$(tput lines)
		tput cup $((lines - 2)) 0

		printf '%*s\n' "$width" '' | tr ' ' '#'

		print -n "Action: [s] system -> git | [l] git -> system | [q] quit "
		read -k1 action

		case $action in
			l)
				while true; do
					clear
					print -n "This is going to replace your existing configuration.nix, are you sure ? (y/n) "
					read -k1 choice
					case $choice in
						y)
							clear
							move_files "dot" "$dots_repository_dir" "$dots_local_dir" ""
							move_files "nixos" "$nix_repository_dir" "$nix_local_dir" "sudo"
							move_files "nixos_common" "$nix_common_repository_dir" "$nix_local_dir" "sudo"
							print "Done. Press any key."
							read -k1
							break
						;;
						n)
							break
						;;
						*)
							clear
							print "Error: wrong input..."
							sleep 3
						;;
					esac
				done
			;;
			q)
				clear
				print "Goodbye $USER !"
				sleep 1
				clear
				break
			;;
			s)
				clear
				move_files "dot" "$dots_local_dir" "$dots_repository_dir" ""
				move_files "nixos" "$nix_local_dir" "$nix_repository_dir" ""
				move_files "nixos_common" "$nix_local_dir" "$nix_common_repository_dir" ""
				print "Done. Press any key."
				read -k1
			;;
			*)
				print "Error: wrong input."
			;;
		esac
	done
}

clear
print "Hello $USER !"
sleep 1

run
