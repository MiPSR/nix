# NixOS configurations
This repository contains my personal NixOS configuration files for various machines.
## Machines
### fuuka
Portable NixOS: a **Samsung USB key** on my **physical keyring**.  
**i3 X11**, running on a **Zen** kernel.  
Runs for a variety of applications.
### homura
Server: a **Dell Optiplex 3040** with an **i3-6100**.  
**Headless**, running on a **hardened** kernel.  
Hosts a few services with Docker.
### ui
Main desktop: a **Ryzen 7 5800X** with an **RX 6700 XT**.  
**KDE Plasma** on **Wayland**, running on a **Zen** kernel.  
Plays games, streams VR content, and handles software development with Nix shells.  
Supports AppImages and Flatpak for applications with limited native support.
## Shared across machines
- Locale is set to `en_US.UTF-8`, with regional settings in `fr_FR`.
- Implemented a fix for sleep issues on B550 motherboards (**ui and fuuka machines only**).
## Shell aliases
### SCRCPY
* `cam <id>`: uses **SCRCPY** to stream a specific camera sensor (by ID) from the device via v4l2.
* `phn`: launches **SCRCPY** with my personal settings.
> **ui and fuuka machines only.**
### NixOS management
* `upd`: updates channels and rebuilds the system with the latest upgrades.
* `cln`: cleans the system by removing old generations (garbage collection).
### Laziness
* `ff`: **fastfetch**.
* `la`: list all files (`ls -a`).
* `ll`: list files in long format (`ls -l`).
* `lla`: list all files in long format (`ls -la`).
## Usage
`useme.zsh` safely transfers configuration files using `$HOST` to prevent modifying unrelated machine configs.
## Flatpak
Flatpak is not declarative (yet, as far as I know), which is inconvenient.
Installed Flatpak applications on **ui**:
- **Bottles** (**fixes VP9 error** in *Blue Archive* and *Stella Sora*)
- **Flatseal**
- **OBS Studio** + plugins
- **osu!** (for faster updates)
