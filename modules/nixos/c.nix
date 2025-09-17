# C/C++ development environment configuration
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # C/C++ compiler
    gcc
    clang

    # Language server
    clang-tools
  ];
}
