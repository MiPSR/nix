# =============================================================================
# TEMPORARY FILE - THIS DOES NOT WORK - DO NOT TRY TO BOOT THIS MACHINE
# =============================================================================
#
# This host module is a throwaway placeholder. It exists purely so that
# `profile-gnome` (see ../../profiles/gnome.nix) has somewhere to be imported
# from, and so the gnome profile gets evaluated by `nix flake check` instead
# of rotting unused in the profiles directory.
#
# It is NOT a working configuration. Read the list below before assuming
# otherwise.
#
# WHAT IS MISSING / BROKEN HERE:
#
#   * There is no `networking.hostName`. Nothing identifies this machine.
#
#   * There is no `system.stateVersion`. NixOS will warn about this on every
#     evaluation. A real host must always pin it, otherwise future nixpkgs
#     behaviour changes cannot be reasoned about.
#
#   * There is no `nixpkgs.hostPlatform`. See the note at the bottom of this
#     file for why that is not here yet.
#
#   * There is no hardware module at all. No kernel modules, no initrd extras,
#     no LUKS, no filesystems, no microcode. `modules/hosts/ui/hardware.nix` is
#     the shape a real host should follow; nothing here resembles it.
#
#   * `profile-gnome` only sets `services.displayManager.defaultSession`.
#     It does NOT enable gnome. There is no `services.desktopManager.gnome`
#     stanza, no gnome session package, and no display manager enabled either.
#     So even if this booted, there would be nothing to log in to.
#
#   * Nothing imports `feature-base`, `feature-gui` or `feature-user-m`, so
#     there is no user, no fontconfig, no pipewire, no greeter, nothing.
#
# IN SHORT: this file is a stub. It evaluates, and `nix flake check` passes,
# but it cannot produce a bootable system. Treat it as scaffolding.
#
# It is written in the same style as `modules/hosts/ui/configuration.nix` so
# that the shape is recognisable, minus every single thing that makes that
# host real.
#
# WHY THERE IS NO `nixosConfigurations.roxy` HERE:
#
#   The obvious setup for this host would be a `nixosConfigurations.roxy`
#   built out of this module, a hardware module and profile-gnome.
#
#   That is deliberately NOT done, because it cannot work yet. A NixOS
#   configuration with nothing but `profile-gnome` in it fails NixOS's own
#   assertions the moment anything forces `system.build.toplevel`:
#
#     - "The 'fileSystems' option does not specify your root file system."
#     - "You must set the option 'boot.loader.grub.devices' or
#        'boot.loader.grub.mirroredBoots' to make the system bootable."
#
#   Those come from nixpkgs, not from anything in this repo, and they cannot be
#   satisfied without a real disk layout and a real bootloader. Wiring a
#   `nixosConfigurations.roxy` in right now would therefore break
#   `nix flake check` for EVERY host in the flake.
#
#   So this file stops at the module. Once roxy has a hardware module with a
#   real `fileSystems` and `boot.loader`, add a `host.nix` next to this one
#   that builds `nixosConfigurations.roxy` from
#   host-roxy-configuration + the hardware module + profile-gnome.
#
# DELETE THIS FILE once the roxy host is actually being set up, and replace it
# with a real configuration at that point.
#
# =============================================================================

{ self, ... }: {
  flake.nixosModules.host-roxy-configuration = { ... }: {
    imports = [
      # Intentionally the only import. See the comment block above: this is a
      # stub, not a real machine. Adding more here is a separate task.
      self.nixosModules.profile-gnome
    ];
  };
}
