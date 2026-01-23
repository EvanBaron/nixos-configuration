# C/C++ development environment configuration
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # C/C++ compiler
    gcc
    glibc
    clang

    # Language server
    clang-tools

    # Debuggers and build tools
    lldb
    gdb
    cmake
    gnumake

    # Add pkg-config and GTK3
    pkg-config
    gtk3
    gtk3.dev
    gdk-pixbuf
  ];
}
