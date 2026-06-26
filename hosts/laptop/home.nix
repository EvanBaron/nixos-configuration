{
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/home-manager/shared.nix
  ];

  home.packages = with pkgs; [
    antigravity-cli
  ];
}
