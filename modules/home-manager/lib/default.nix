{ pkgs, lib, ... }:

let
  colors = import ./colors.nix { inherit lib; };
  hexToRgb = colors.hexToRgb;
in
{
  inherit colors;
  builders = import ./builders.nix { inherit pkgs lib; };
  discord = import ./discord-theme.nix { inherit hexToRgb; };
  obsidian = import ./obsidian-theme.nix { inherit hexToRgb; };
  zed = import ./zed-theme.nix;
}
