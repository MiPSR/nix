{ hostname, ... }:

let
  palette = import ../../../palette.nix;
in

{
  xdg.configFile."anyrun/config.ron" = {
    force = true;
    text = ''
      			Config(
      				// Top center, krunner-style.
      				x: Fraction(0.5),
      				y: Fraction(0.3),
      				width: Fraction(0.3),
      				height: Absolute(1),

      				hide_plugin_info: true,
      				close_on_click: true,

      				// Plugin names resolve via ANYRUN_PLUGINS, set by the nixpkgs package.
      				plugins: [
      					"libapplications.so",
      					"libsymbols.so",
      					"libshell.so",
      					"libtranslate.so",
      				],
      			)
      		'';
  };

  xdg.configFile."anyrun/style.css" = {
    force = true;
    text = ''
      			@define-color accent ${palette.brightBlue};
      			@define-color bg-color ${palette.black};
      			@define-color fg-color ${palette.light};
      			@define-color desc-color ${palette.dark};

      			window {
      				background: transparent;
      			}

      			box.main {
      				padding: 5px;
      				margin: 10px;
      				border-radius: 0;
      				border: 4px solid @accent;
      				background-color: @bg-color;
      			}

      			text {
      				min-height: 30px;
      				padding: 5px;
      				color: @fg-color;
      				caret-color: @fg-color;
      			}

      			.matches {
      				background-color: rgba(0, 0, 0, 0);
      			}

      			box.plugin:first-child {
      				margin-top: 5px;
      			}

      			box.plugin.info {
      				min-width: 200px;
      			}

      			list.plugin {
      				background-color: rgba(0, 0, 0, 0);
      			}

      			label.match {
      				color: @fg-color;
      			}

      			label.match.description {
      				font-size: 10px;
      				color: @desc-color;
      			}

      			label.plugin.info {
      				font-size: 14px;
      				color: @fg-color;
      			}

      			.match {
      				background: transparent;
      			}

      			.match:selected {
      				border-left: 4px solid @accent;
      				background: transparent;
      				animation: fade 0.1s linear;
      			}

      			@keyframes fade {
      				0% { opacity: 0; }
      				100% { opacity: 1; }
      			}
      		'';
  };
}
