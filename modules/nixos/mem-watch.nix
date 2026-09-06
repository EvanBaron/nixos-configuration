{ pkgs, ... }:

let
  script = pkgs.writeShellScript "mem-watch" ''
    echo "=== $(date -Iseconds) ==="
    ${pkgs.procps}/bin/free -h | sed -n '1,2p'
    ${pkgs.procps}/bin/ps -eo pid,comm,%mem,rss --sort=-rss --no-headers | head -n 8 |
      ${pkgs.gawk}/bin/awk '{ printf "  pid=%-7s rss=%-8.0fMB mem=%-5s%% cmd=%s\n", $1, $4/1024, $3, $2 }'
  '';
in
{
  systemd.services.mem-watch = {
    description = "Log top memory-consuming processes";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${script}";
    };
  };

  systemd.timers.mem-watch = {
    description = "Periodically run mem-watch";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "1min";
      Unit = "mem-watch.service";
    };
  };
}
