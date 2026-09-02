{
  systemd.user.tmpfiles.rules = [
    "L+ %h/.local/share/fonts - - - - /run/current-system/sw/share/X11/fonts"
  ];
}
