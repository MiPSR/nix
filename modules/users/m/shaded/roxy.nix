{ pkgs, ... }:

{
  home.packages = with pkgs; [
    code-cursor
    darktable
    (pkgs.discord.override { withVencord = true; })
    (pkgs.discord-ptb.override { withVencord = true; })
    drawpile
    google-chrome
    interlude
    krita
    libreoffice-qt
    moonlight-qt
    opencode
    openutau
    osu-lazer-bin
    parsec-bin
    pixelorama
    rconc
    thunderbird-esr
    vscodium-fhs
    vscode
  ];

  xdg.desktopEntries.steam2 = {
    name = "Steam2";
    type = "Application";
    exec = "gamescope -e -f -W 1920 -H 1080 -- steam -gamepadui -steamos3 -steampal -steamdeck";
    icon = "steam";
    categories = [ "Game" ];
  };

  xdg.desktopEntries.osu2 = {
    name = "osu!2";
    type = "Application";
    exec = "gamescope -f -W 1280 -H 720 -- osu!";
    icon = "osu!";
    categories = [ "Game" ];
  };
}
