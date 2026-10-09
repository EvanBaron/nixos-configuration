# sops-nix: secrets live encrypted in a repo and are decrypted at login
# into $XDG_RUNTIME_DIR. The age key is the one thing to back up by hand.
#   create:  age-keygen -o ~/.config/sops/age/keys.txt
#   edit:    sops secrets/<file>   (recipients come from .sops.yaml)
{ config, pkgs, ... }:

{
  sops.age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

  home.packages = with pkgs; [
    sops
    age
  ];
}
