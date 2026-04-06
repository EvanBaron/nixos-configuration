# Android development environment configuration
{ pkgs, ... }:

let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "35" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" ];
    abiVersions = [ "x86_64" ];
    includeSources = false;
  };
in
{
  nixpkgs.config.android_sdk.accept_license = true;

  # Install Android development tools
  environment.systemPackages = [
    pkgs.android-studio
    androidComposition.androidsdk
    pkgs.android-tools
  ];

  # Set Android SDK path for development tools
  environment.sessionVariables = {
    ANDROID_HOME = "${androidComposition.androidsdk}/share/android-sdk";
  };
}
