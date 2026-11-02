{ pkgs, lib, ... }:

let
  colors = import ./colors.nix { inherit lib; };
  inherit (colors) hexToRgb hexToHsl;
in
{
  inherit colors;
  builders = import ./builders.nix { inherit pkgs lib; };
  discord = import ./discord-theme.nix { inherit hexToRgb; };
  obsidian = import ./obsidian-theme.nix { inherit hexToRgb hexToHsl; };
  zed = import ./zed-theme.nix;
}
