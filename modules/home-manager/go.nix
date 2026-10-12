{
  config,
  pkgs,
  ...
}:

let
  goPath = "${config.xdg.dataHome}/go";
in
{
  programs.go = {
    enable = true;
    env = {
      GOPATH = goPath;
    };
    telemetry.mode = "off";
  };

  home.packages = with pkgs; [
    # Language server, debugger and linters
    gopls
    delve
    golangci-lint
    gotools
  ];

  # Binaries installed with `go install`
  home.sessionPath = [ "${goPath}/bin" ];
}
