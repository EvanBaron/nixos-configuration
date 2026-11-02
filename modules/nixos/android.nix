# Android development environment configuration
#
# The SDK lives in ~/Android/Sdk (ANDROID_HOME), which stays writable so Gradle
# can fetch the build-tools/platforms/NDK each project asks for. Nix only
# provides a bootstrap sdkmanager to fetch cmdline-tools, whose `android sdk`
# then installs the packages below; run `android-sdk-sync`. No Android Studio
# involved.
{ pkgs, ... }:

let
  sdk = "/home/ebaron/Android/Sdk";

  # Packages kept in ~/Android/Sdk; Gradle installs the rest on demand.
  # cmdline-tools/latest is where avdmanager is looked up by Expo's device hub.
  sdkPackages = [
    "cmdline-tools/latest"
    "platform-tools"
    "emulator"
    "system-images/android-36.1/google_apis_playstore_ps16k/x86_64"
  ];

  # Only used to bootstrap ~/Android/Sdk; the image-less SDK keeps the store small.
  bootstrapSdk =
    (pkgs.androidenv.composeAndroidPackages {
      platformVersions = [ ];
      buildToolsVersions = [ ];
      includeCmake = false;
    }).androidsdk;

  androidSdkSync = pkgs.writeShellApplication {
    name = "android-sdk-sync";
    runtimeInputs = [ pkgs.openjdk17 ];
    text = ''
      android="${sdk}/cmdline-tools/latest/bin/android"
      if [ ! -x "$android" ]; then
        sdkmanager=$(echo ${bootstrapSdk}/libexec/android-sdk/cmdline-tools/*/bin/sdkmanager)
        yes | "$sdkmanager" --sdk_root="${sdk}" --licenses > /dev/null || true
        "$sdkmanager" --sdk_root="${sdk}" "cmdline-tools;latest"
      fi
      "$android" --sdk="${sdk}" sdk install ${pkgs.lib.escapeShellArgs sdkPackages} "$@"
    '';
  };
in
{
  nixpkgs.config.android_sdk.accept_license = true;

  # Enable nix-ld to run the unpatched SDK binaries (emulator, adb, aapt2, ...)
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

  environment.systemPackages = [
    androidSdkSync
    # Expo's device hub encodes the emulator stream with ffmpeg/ffprobe
    pkgs.ffmpeg
  ];

  environment.sessionVariables = {
    ANDROID_HOME = sdk;
    ANDROID_SDK_ROOT = sdk;
    PATH = [
      "${sdk}/cmdline-tools/latest/bin"
      "${sdk}/emulator"
      "${sdk}/platform-tools"
    ];
  };
}
