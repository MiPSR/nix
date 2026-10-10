{ self, ... }: {
  flake.nixosModules.feature-caddy = { lib, ... }: {
    containers.caddy = {
      autoStart = true;
      restartIfChanged = true;
      privateNetwork = true;
      hostBridge = "bridge_services";
      localAddress = "192.168.244.101/24";

      config =
        { pkgs, ... }:
        let
          dashboard = ''
            <!DOCTYPE html>
            <html lang='en'>
            <head>
            <meta charset='utf-8'>
            <meta name='viewport' content='width=device-width,initial-scale=1'>
            <title>homura</title>
            <style>
              :root { color-scheme: dark; }
              * { box-sizing: border-box; }
              body {
                margin: 0; padding: 2.5rem 1.25rem; min-height: 100vh;
                background: #0d1117; color: #e6edf3;
                font: 15px/1.6 ui-sans-serif, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
              }
              .wrap { max-width: 940px; margin: 0 auto; }
              h1 { margin: 0; font-size: 1.5rem; font-weight: 700; letter-spacing: -.02em; }
              .sub { margin: .4rem 0 2rem; color: #8b949e; font-size: .875rem; }
              section {
                background: #161b22; border: 1px solid #30363d; border-radius: 10px;
                margin-bottom: 1.25rem; overflow: hidden;
              }
              .head { display: flex; align-items: center; gap: .6rem;
                      padding: .9rem 1.15rem; border-bottom: 1px solid #30363d; }
              .head h2 { margin: 0; font-size: 1rem; font-weight: 600; }
              .pill {
                margin-left: auto; font-size: .7rem; font-weight: 600;
                letter-spacing: .04em; text-transform: uppercase;
                padding: .2rem .5rem; border-radius: 999px;
                background: rgba(63,185,80,.15); color: #3fb950;
              }
              dl { margin: 0; display: grid; grid-template-columns: 9rem 1fr; gap: 0; }
              dt, dd { margin: 0; padding: .6rem 1.15rem; border-bottom: 1px solid #21262d; }
              dt { color: #8b949e; font-size: .8125rem; }
              dd { font-size: .875rem; font-variant-numeric: tabular-nums; }
              tr:last-child dt, tr:last-child dd { border-bottom: 0; }
              footer { margin-top: 2rem; color: #6e7681; font-size: .8125rem; }
              code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: .8125rem; }
            </style>
            </head>
            <body>
            <div class='wrap'>
              <h1>homura</h1>
              <p class='sub'>DHCP on both networks. This page is static: it reports
              configuration, not live leases.</p>

              <section>
                <div class='head'>
                  <h2>LAN</h2>
                  <span class='pill'>kea up</span>
                </div>
                <dl>
                  <dt>Network</dt><dd><code>192.168.144.0/24</code></dd>
                  <dt>Bridge</dt><dd><code>bridge_lan_144</code></dd>
                  <dt>Gateway</dt><dd><code>192.168.144.254</code></dd>
                  <dt>DHCP server</dt><dd><code>192.168.144.100</code></dd>
                  <dt>Pool</dt><dd><code>192.168.144.1 - 192.168.144.99</code></dd>
                  <dt>DNS</dt><dd><code>192.168.244.100</code> (blocky)</dd>
                  <dt>Port</dt><dd><code>enp2s0</code></dd>
                </dl>
              </section>

              <section>
                <div class='head'>
                  <h2>WiFi &middot; 미유</h2>
                  <span class='pill'>kea up</span>
                </div>
                <dl>
                  <dt>Network</dt><dd><code>192.168.100.0/24</code></dd>
                  <dt>Bridge</dt><dd><code>bridge_wifi_100</code></dd>
                  <dt>Gateway</dt><dd><code>192.168.100.254</code></dd>
                  <dt>DHCP server</dt><dd><code>192.168.100.100</code></dd>
                  <dt>Pool</dt><dd><code>192.168.100.1 - 192.168.100.99</code></dd>
                  <dt>DNS</dt><dd><code>192.168.200.100</code> (blocky, Cloudflare DoT/DoH)</dd>
                  <dt>Radio</dt><dd><code>wlp0s20f0u6</code>, 2.4 GHz, channel 6</dd>
                  <dt>Security</dt><dd>WPA3-Personal (SAE), CCMP, PMF required</dd>
                </dl>
              </section>

              <section>
                <div class='head'>
                  <h2>Services</h2>
                </div>
                <dl>
                  <dt>Network</dt><dd><code>192.168.244.0/24</code> on <code>bridge_services</code></dd>
                  <dt>DNS</dt><dd><code>192.168.244.100</code> blocky</dd>
                  <dt>Blocky API</dt><dd><code>192.168.244.100:4000</code></dd>
                  <dt>This page</dt><dd><code>192.168.244.101</code> caddy, as <code>info.lan</code></dd>
                  <dt>Minecraft</dt><dd><code>192.168.244.110</code>, published on 25565</dd>
                </dl>
              </section>

              <footer>WiFi clients reach the internet, this page and their own
              resolver on <code>192.168.200.100</code>. They cannot reach the
              LAN; on the services network only this page and the blocky API
              are open to them.</footer>
            </div>
            </body>
            </html>
          '';
        in
        {
          system.stateVersion = "26.05";

          networking.enableIPv6 = false;

          nix.enable = false;

          networking.defaultGateway = "192.168.244.254";
          networking.nameservers = [ "192.168.244.100" ];

          networking.firewall.allowedTCPPorts = [
            80
            443
          ];

          services.caddy = {
            enable = true;
            openFirewall = false;

            configFile = pkgs.writeText "Caddyfile" ''
              http://info.lan {
                header Content-Type "text/html; charset=utf-8"
                respond <<HTMLDASH
              ${dashboard}
              HTMLDASH 200
              }

              vault.cunny.fr {
                reverse_proxy 192.168.244.120:8000
              }
            '';
          };
        };
    };

    networking.nat.forwardPorts = [
      {
        sourcePort = 80;
        destination = "192.168.244.101:80";
      }
      {
        sourcePort = 443;
        destination = "192.168.244.101:443";
      }
    ];

    systemd.services."container@caddy" = {
      after = [ "NetworkManager-ensure-profiles.service" ];
      wants = [ "NetworkManager-ensure-profiles.service" ];
      startLimitBurst = 3;
      startLimitIntervalSec = 60;
    };
  };
}
