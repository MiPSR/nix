{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  # Noctalia replaces bar, notifications, launcher, lockscreen, wallpaper, and terminal/shell services
  environment.systemPackages = with pkgs; [
    alacritty
    hyprshot
    noctalia
    wl-gammactl
    xdg-desktop-portal-hyprland
  ];

  # Hardcoded Lua configuration in /etc/xdg/hypr/hyprland.lua
  environment.etc."xdg/hypr/hyprland.lua".text = ''
    -- Official example hyprland.lua

    -- Monitors
    hl.monitor({
        output   = "",
        mode     = "highres",
        position = "auto",
        scale    = 1,
    })

    -- Autostart
    hl.on("hyprland.start", function()
        hl.exec_cmd("noctalia")
        hl.exec_cmd("command -v kanshi >/dev/null 2>&1 && kanshi")
        hl.exec_cmd("command -v wl-gammactl >/dev/null 2>&1 && hyprctl monitors | grep -qi panasonic && wl-gammactl -g 1.6")
    end)

    -- Environment variables
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")

    -- Look and feel
    hl.config({
        general = {
            gaps_in        = 5,
            gaps_out       = 20,
            border_size    = 2,
            col = {
                active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
                inactive_border = "rgba(595959aa)",
            },
            resize_on_border = false,
            allow_tearing    = false,
            layout           = "dwindle",
        },
        decoration = {
            rounding         = 10,
            active_opacity   = 1.0,
            inactive_opacity = 1.0,
            shadow = {
                enabled      = true,
                range        = 4,
                render_power = 3,
                color        = 0xee1a1a1a,
            },
            blur = {
                enabled  = true,
                size     = 3,
                passes   = 1,
                vibrancy = 0.1696,
            },
        },
        animations = {
            enabled = true,
        },
        dwindle = {
            preserve_split = true,
        },
        master = {
            new_status = "master",
        },
        misc = {
            force_default_wallpaper = -1,
            disable_hyprland_logo   = false,
        },
        input = {
            kb_layout   = "us",
            follow_mouse = 1,
            sensitivity = 0,
            touchpad = {
                natural_scroll = false,
            },
        },
    })

    -- Curves and animations
    hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 }    } })
    hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 }    } })
    hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 }       } })
    hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 }    } })
    hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 }     } })

    hl.animation({ leaf = "global",     enabled = true, speed = 10,   bezier = "default" })
    hl.animation({ leaf = "border",     enabled = true, speed = 5.39, bezier = "easeOutQuint" })
    hl.animation({ leaf = "windows",    enabled = true, speed = 4.79, bezier = "easeOutQuint" })
    hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
    hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
    hl.animation({ leaf = "fadeIn",     enabled = true, speed = 1.73, bezier = "almostLinear" })
    hl.animation({ leaf = "fadeOut",    enabled = true, speed = 1.46, bezier = "almostLinear" })
    hl.animation({ leaf = "fade",       enabled = true, speed = 3.03, bezier = "quick" })
    hl.animation({ leaf = "layers",     enabled = true, speed = 3.81, bezier = "easeOutQuint" })
    hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

    -- Keybindings
    local mainMod = "SUPER"
    local terminal = "alacritty"

    hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
    hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd("noctalia msg panel-open launcher"))
    hl.bind(mainMod .. " + C", hl.dsp.window.close())
    hl.bind(mainMod .. " + M", hl.dsp.exit())
    hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
    hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

    -- Screenshots (hyprshot, clipboard-only, non-interactive except region)
    hl.bind("Print",        hl.dsp.exec_cmd("hyprshot -m output -m active --clipboard-only"))
    hl.bind("ALT + Print",  hl.dsp.exec_cmd("hyprshot -m window -m active --clipboard-only"))
    hl.bind("CTRL + Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))

    -- Focus movement
    hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
    hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
    hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

    -- Workspaces
    for i = 1, 10 do
        local key = i % 10
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
    end

    -- Mouse binds
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
  '';
}