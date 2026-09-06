# Android development environment configuration
{ pkgs, ... }:

let
  androidComposition = pkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "35" "36" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis" "google_apis_playstore" ];
    abiVersions = [ "x86_64" "arm64-v8a" ];
    includeSources = false;
  };

  # Wrap Android Studio to run emulator on XCB (Wayland fix)
  androidStudioWrapped = pkgs.symlinkJoin {
    name = "android-studio-wrapped";
    paths = [ pkgs.android-studio ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/android-studio \
        --set QT_QPA_PLATFORM xcb
    '';
  };

  # Wrap the emulator binary to force xcb
  androidSdkWrapped = pkgs.symlinkJoin {
    name = "android-sdk-wrapped";
    paths = [ androidComposition.androidsdk ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/emulator \
        --set QT_QPA_PLATFORM xcb
    '';
  };
in
{
  nixpkgs.config.android_sdk.accept_license = true;

  # Enable nix-ld to run unpatched binaries like the Android emulator
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    libpng
    glib
    libbsd
    libX11
    libXext
    libXrender
    libXi
    libXcursor
    libXinerama
    libXrandr
    libXcomposite
    libXdamage
    libXft
    libXmu
    libXt
    libxcb
    libXau
    libXpm
    libxkbfile
    libsm
    libice
    libxcb-cursor
    libxcb-util
    libxcb-wm
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    freetype
    fontconfig
    pulseaudio
    alsa-lib
    libGL
    libGLU
    libglvnd
  ];

  # Install Android development tools
  environment.systemPackages = [
    androidStudioWrapped
    androidSdkWrapped
    pkgs.android-tools
  ];

  # Set Android SDK path to the user's writable directory
  # so Android Studio can download and run modern SDK components/AVDs.
  environment.sessionVariables = {
    ANDROID_HOME = "/home/ebaron/Android/Sdk";
    ANDROID_SDK_ROOT = "/home/ebaron/Android/Sdk";
  };
}
