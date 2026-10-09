{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.gnome-network-displays ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall = {
    allowedTCPPorts = [
      7236
      7250
    ];
    allowedUDPPorts = [ 7236 ];
    trustedInterfaces = [ "p2p-wl+" ];

    extraCommands = ''
      iptables -A nixos-fw -p udp --sport 5353 -j nixos-fw-accept
      iptables -A nixos-fw -p udp --sport 1900 -j nixos-fw-accept
    '';
    extraStopCommands = ''
      iptables -D nixos-fw -p udp --sport 5353 -j nixos-fw-accept || true
      iptables -D nixos-fw -p udp --sport 1900 -j nixos-fw-accept || true
    '';
  };
}
