{ hostname, pkgs, ... }:

let
  palette = import ../../../palette.nix;
in

{
  programs.neovim = {
    enable = true;
    extraConfig = ''
      			set termguicolors
      			colorscheme m
      		'';
    plugins = with pkgs.vimPlugins; [
      neo-tree-nvim
      nui-nvim
      nvim-web-devicons
      plenary-nvim
    ];
  };

  xdg.configFile."nvim/colors/m.lua" = {
    force = true;
    text = ''
      			vim.cmd("highlight clear")
      			vim.g.colors_name = "m"

      			local hi = vim.api.nvim_set_hl

      			-- UI.
      			hi(0, "Normal", { fg = "${palette.light}" })
      			hi(0, "NormalFloat", { fg = "${palette.light}", bg = "${palette.black}" })
      			hi(0, "FloatBorder", { fg = "${palette.blue}", bg = "${palette.black}" })
      			hi(0, "FloatTitle", { fg = "${palette.brightBlue}", bg = "${palette.black}" })
      			hi(0, "EndOfBuffer", { fg = "${palette.black}" })
      			hi(0, "NonText", { fg = "${palette.black}" })
      			hi(0, "Whitespace", { fg = "${palette.black}" })

      			hi(0, "Comment", { fg = "${palette.dark}", italic = true })
      			hi(0, "Cursor", { fg = "${palette.black}", bg = "${palette.brightBlue}" })
      			hi(0, "lCursor", { fg = "${palette.black}", bg = "${palette.brightBlue}" })
      			hi(0, "CursorIM", { fg = "${palette.black}", bg = "${palette.brightBlue}" })
      			hi(0, "TermCursor", { fg = "${palette.black}", bg = "${palette.brightBlue}" })

      			hi(0, "Visual", { fg = "${palette.white}", bg = "${palette.blue}" })
      			hi(0, "VisualNOS", { bg = "${palette.blue}" })
      			hi(0, "Search", { fg = "${palette.black}", bg = "${palette.brightYellow}" })
      			hi(0, "IncSearch", { fg = "${palette.black}", bg = "${palette.brightBlue}" })
      			hi(0, "CurSearch", { fg = "${palette.black}", bg = "${palette.brightBlue}" })
      			hi(0, "MatchParen", { fg = "${palette.black}", bg = "${palette.brightBlue}" })

      			hi(0, "LineNr", { fg = "${palette.dark}" })
      			hi(0, "CursorLineNr", { fg = "${palette.brightBlue}" })
      			hi(0, "SignColumn", { fg = "${palette.dark}" })
      			hi(0, "Folded", { fg = "${palette.dark}" })
      			hi(0, "FoldColumn", { fg = "${palette.dark}" })

      			hi(0, "StatusLine", { fg = "${palette.black}", bg = "${palette.brightBlue}" })
      			hi(0, "StatusLineNC", { fg = "${palette.dark}", bg = "${palette.black}" })
      			hi(0, "WinSeparator", { fg = "${palette.dark}" })
      			hi(0, "WinBar", { fg = "${palette.light}" })
      			hi(0, "WinBarNC", { fg = "${palette.dark}" })

      			hi(0, "Pmenu", { fg = "${palette.light}", bg = "${palette.black}" })
      			hi(0, "PmenuSel", { fg = "${palette.black}", bg = "${palette.brightBlue}" })
      			hi(0, "PmenuSbar", { bg = "${palette.black}" })
      			hi(0, "PmenuThumb", { bg = "${palette.dark}" })
      			hi(0, "PmenuKind", { fg = "${palette.dark}", bg = "${palette.black}" })
      			hi(0, "PmenuExtra", { fg = "${palette.dark}", bg = "${palette.black}" })

      			hi(0, "ModeMsg", { fg = "${palette.dark}" })
      			hi(0, "MsgArea", { fg = "${palette.light}" })
      			hi(0, "MoreMsg", { fg = "${palette.brightBlue}" })
      			hi(0, "Question", { fg = "${palette.brightGreen}" })
      			hi(0, "Title", { fg = "${palette.brightBlue}" })
      			hi(0, "Directory", { fg = "${palette.brightBlue}" })
      			hi(0, "ErrorMsg", { fg = "${palette.brightRed}" })
      			hi(0, "WarningMsg", { fg = "${palette.brightYellow}" })
      			hi(0, "Todo", { fg = "${palette.black}", bg = "${palette.brightYellow}", bold = true })
      			hi(0, "Underlined", { fg = "${palette.brightBlue}", underline = true })
      			hi(0, "Conceal", { fg = "${palette.dark}" })

      			hi(0, "SpellBad", { sp = "${palette.brightRed}", undercurl = true })
      			hi(0, "SpellCap", { sp = "${palette.brightBlue}", undercurl = true })
      			hi(0, "SpellRare", { sp = "${palette.brightMagenta}", undercurl = true })
      			hi(0, "SpellLocal", { sp = "${palette.brightBlue}", undercurl = true })

      			hi(0, "DiffAdd", { fg = "${palette.brightGreen}" })
      			hi(0, "DiffChange", { fg = "${palette.brightYellow}" })
      			hi(0, "DiffDelete", { fg = "${palette.brightRed}" })
      			hi(0, "DiffText", { fg = "${palette.black}", bg = "${palette.brightYellow}" })
      			hi(0, "Added", { fg = "${palette.brightGreen}" })
      			hi(0, "Changed", { fg = "${palette.brightYellow}" })
      			hi(0, "Removed", { fg = "${palette.brightRed}" })

      			-- Syntax.
      			hi(0, "Constant", { fg = "${palette.brightBlue}" })
      			hi(0, "String", { fg = "${palette.brightGreen}" })
      			hi(0, "Character", { fg = "${palette.brightGreen}" })
      			hi(0, "Number", { fg = "${palette.brightYellow}" })
      			hi(0, "Boolean", { fg = "${palette.brightRed}" })
      			hi(0, "Float", { fg = "${palette.brightYellow}" })

      			hi(0, "Identifier", { fg = "${palette.light}" })
      			hi(0, "Function", { fg = "${palette.brightBlue}" })

      			hi(0, "Statement", { fg = "${palette.brightMagenta}" })
      			hi(0, "Conditional", { fg = "${palette.brightMagenta}" })
      			hi(0, "Repeat", { fg = "${palette.brightMagenta}" })
      			hi(0, "Label", { fg = "${palette.brightYellow}" })
      			hi(0, "Operator", { fg = "${palette.brightBlue}" })
      			hi(0, "Keyword", { fg = "${palette.brightMagenta}" })
      			hi(0, "Exception", { fg = "${palette.brightRed}" })

      			hi(0, "PreProc", { fg = "${palette.brightYellow}" })
      			hi(0, "Include", { fg = "${palette.brightYellow}" })
      			hi(0, "Define", { fg = "${palette.brightYellow}" })
      			hi(0, "Macro", { fg = "${palette.brightYellow}" })
      			hi(0, "PreCondit", { fg = "${palette.brightYellow}" })

      			hi(0, "Type", { fg = "${palette.brightBlue}" })
      			hi(0, "StorageClass", { fg = "${palette.brightBlue}" })
      			hi(0, "Structure", { fg = "${palette.brightBlue}" })
      			hi(0, "Typedef", { fg = "${palette.brightBlue}" })

      			hi(0, "Special", { fg = "${palette.brightYellow}" })
      			hi(0, "SpecialChar", { fg = "${palette.brightRed}" })
      			hi(0, "Tag", { fg = "${palette.brightBlue}" })
      			hi(0, "Delimiter", { fg = "${palette.dark}" })
      			hi(0, "SpecialComment", { fg = "${palette.dark}" })
      			hi(0, "Debug", { fg = "${palette.brightRed}" })
      		'';
  };
}
