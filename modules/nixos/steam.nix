{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraPkgs =
        pkgs: with pkgs; [
          qt5.qtbase # Add Qt5 libraries for better compatibility
        ];
    };
  };

  # Enable 32-bit support for Steam
  hardware.graphics.enable32Bit = true;
  services.pulseaudio.support32Bit = true;

  # Allow unfree packages for Steam
  nixpkgs.config.allowUnfree = true;
}
