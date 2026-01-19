# NixOS configurations

This repository contains my personal NixOS configuration files for various setups.

## homura

Server: a **Dell Optiplex 3040** with an **i3-6100**.  
Configured to host a few services with Docker.  
Runs on the **hardened** kernel.

## ui

Main desktop: a **Ryzen 7 5800X** with an **RX 6700 XT**.  
Configured for gaming, VR, and software development using Nix shells.  
Supports AppImages, has Android tools (adb + SCRCPY), and runs on the **Zen** kernel.  
Implemented a fix for sleep issues on B550 motherboards.

## Shared across machines

Locale is set to `en_US.UTF-8`, with regional settings in `fr_FR`.

## Shell aliases

### SCRCPY
* `cam <id>`: uses **SCRCPY** to stream a specific camera sensor (by ID) from the device via v4l2.
* `phn`: launches **SCRCPY** with my personal settings.

### NixOS management
* `upd`: updates channels and rebuilds the system with the latest upgrades.
* `cln`: cleans the system by removing old generations (garbage collection).

### Laziness
* `ff`: **fastfetch**.
* `la`: list all files (`ls -a`).
* `ll`: list files in long format (`ls -l`).
* `lla`: list all files in long format (`ls -la`).
