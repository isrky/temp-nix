{ pkgs, ... }:
{
  # Remotely-managed Cloudflare Tunnel (token-based).
  # Equivalent of `cloudflared service install <token>`, but declarative.
  #
  # The token is a secret, so it lives in /etc/cloudflared/token.env
  # (root-only, outside git and the Nix store) rather than inline here.
  # That file must contain:
  #   TUNNEL_TOKEN=eyJhIjoi...
  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      EnvironmentFile = "/etc/cloudflared/token.env";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token \${TUNNEL_TOKEN}";
      Restart = "on-failure";
      RestartSec = 5;
      DynamicUser = true;
    };
  };
}
