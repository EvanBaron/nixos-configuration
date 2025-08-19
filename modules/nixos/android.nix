# Android development environment configuration
{ pkgs, ... }:

{
  # Install Android development tools
  environment.systemPackages = [
    pkgs.android-studio
    pkgs.android-tools
  ];

  # Set Android SDK path for development tools
  environment.sessionVariables = {
    ANDROID_HOME = "${pkgs.android-tools}/share/android-sdk";
  };
}
