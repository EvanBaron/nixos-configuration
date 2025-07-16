{ pkgs, ... }:

{
  users.users.ebaron.extraGroups = [
    "kvm"
    "adbusers"
  ];

  environment.systemPackages = [
    pkgs.android-studio
    pkgs.android-tools
  ];

  environment.sessionVariables = {
    ANDROID_HOME = "${pkgs.android-tools}/share/android-sdk";
  };
}
