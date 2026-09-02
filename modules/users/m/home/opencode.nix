{ hostname, ... }:

let
  palette = import ../../../palette.nix;

  theme = {
    accent = palette.brightBlue;
    background = palette.black;
    backgroundElement = palette.black;
    backgroundPanel = palette.black;
    border = palette.blue;
    borderActive = palette.brightBlue;
    borderSubtle = palette.black;
    diffAdded = palette.brightGreen;
    diffAddedBg = palette.black;
    diffAddedLineNumberBg = palette.black;
    diffContext = palette.dark;
    diffContextBg = palette.black;
    diffHighlightAdded = palette.green;
    diffHighlightRemoved = palette.red;
    diffHunkHeader = palette.dark;
    diffLineNumber = palette.dark;
    diffRemoved = palette.brightRed;
    diffRemovedBg = palette.black;
    diffRemovedLineNumberBg = palette.black;
    error = palette.brightRed;
    info = palette.brightBlue;
    markdownBlockQuote = palette.dark;
    markdownCode = palette.brightGreen;
    markdownCodeBlock = palette.light;
    markdownEmph = palette.brightMagenta;
    markdownHeading = palette.brightBlue;
    markdownHorizontalRule = palette.dark;
    markdownImage = palette.brightBlue;
    markdownImageText = palette.brightBlue;
    markdownLink = palette.brightBlue;
    markdownLinkText = palette.brightBlue;
    markdownListEnumeration = palette.brightBlue;
    markdownListItem = palette.brightBlue;
    markdownStrong = palette.white;
    markdownText = palette.light;
    primary = palette.brightBlue;
    secondary = palette.blue;
    success = palette.brightGreen;
    syntaxComment = palette.dark;
    syntaxFunction = palette.brightBlue;
    syntaxKeyword = palette.brightMagenta;
    syntaxNumber = palette.brightYellow;
    syntaxOperator = palette.brightBlue;
    syntaxPunctuation = palette.dark;
    syntaxString = palette.brightGreen;
    syntaxType = palette.brightBlue;
    syntaxVariable = palette.light;
    text = palette.light;
    textMuted = palette.dark;
    warning = palette.brightYellow;
  };
in
{
  xdg.configFile."opencode/themes/m.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/theme.json";
    inherit theme;
  };

  xdg.configFile."opencode/tui.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/tui.json";
    theme = "m";
  };
}
