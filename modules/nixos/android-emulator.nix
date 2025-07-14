{ pkgs, ... }:

{
  programs.adb.enable = true;
  users.users.ebaron.extraGroups = [
    "kvm"
    "adbusers"
  ];

  environment.systemPackages = [ pkgs.android-studio ];

  environment.sessionVariables = {
    ANDROID_HOME = "/home/ebaron/Android/Sdk";
  };
}
