# Android development environment configuration
{ pkgs, ... }:

{
  # Add user to required groups for Android development
  users.users.ebaron.extraGroups = [
    "kvm"
    "adbusers"
  ];

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
