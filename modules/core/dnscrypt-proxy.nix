{ pkgs, ... }:
{
  networking = {
    nameservers = [ "127.0.0.1" ];
    dhcpcd.extraConfig = "nohook resolv.conf";
    firewall.checkReversePath = "loose";
  };

  services.tailscale = {
    enable = true;
    extraSetFlags = [ "--accept-dns=false" ];
  };

  services.dnscrypt-proxy2 = {
    enable = true;
    upstreamDefaults = false;

    settings = {
      listen_addresses = [ "127.0.0.1:53" ];

      server_names     = [];
      ipv4_servers     = true;
      ipv6_servers     = false;
      block_ipv6       = true;
      dnscrypt_servers = true;
      doh_servers      = false;
      odoh_servers     = false;

      require_dnssec   = true;
      require_nolog    = true;
      require_nofilter = true;

      cache_size        = 4096;
      cache_min_ttl     = 2400;
      cache_max_ttl     = 86400;
      cache_neg_min_ttl = 60;
      cache_neg_max_ttl = 600;

      blocked_ips.blocked_ips_file = "/etc/dnscrypt-proxy/blocked-ips.txt";
      forwarding_rules = "/etc/dnscrypt-proxy/forwarding-rules.txt";

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file   = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      sources.relays = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
          "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
        ];
        cache_file   = "/var/cache/dnscrypt-proxy/relays.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      anonymized_dns = {
        routes = [
          { server_name = "*"; via = [ "*" ]; }
        ];
        skip_incompatible = true;
      };

      local_doh = {
        listen_addresses = [ "127.0.0.1:3000" ];
        path             = "/dns-query";
        cert_file        = "/etc/dnscrypt-proxy/localhost.pem";
        cert_key_file    = "/etc/dnscrypt-proxy/localhost.pem";
      };
    };
  };

  environment.systemPackages = with pkgs; [ openssl ];

  environment.etc."dnscrypt-proxy/forwarding-rules.txt" = {
    mode = "0644";
    text = ''
      ts.net  100.100.100.100
    '';
  };

  environment.etc."dnscrypt-proxy/blocked-ips.txt" = {
    mode = "0644";
    text = ''
      0.0.0.0
      127.*
      10.*
      172.16.*
      172.17.*
      172.18.*
      172.19.*
      172.20.*
      172.21.*
      172.22.*
      172.23.*
      172.24.*
      172.25.*
      172.26.*
      172.27.*
      172.28.*
      172.29.*
      172.30.*
      172.31.*
      192.168.*
      169.254.*
    '';
  };
}
