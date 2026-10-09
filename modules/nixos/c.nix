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
    bear # generates compile_commands.json for clangd from any build (bear -- make)

    # Add pkg-config and GTK3
    pkg-config
    gtk3
    gtk3.dev
    gdk-pixbuf

    # Unit testing
    criterion
    criterion.dev
  ];

  environment.variables = {
    CPATH = [ "${pkgs.criterion.dev}/include" ];
    LIBRARY_PATH = [ "${pkgs.criterion}/lib" ];
    PKG_CONFIG_PATH = [ "${pkgs.criterion.dev}/lib/pkgconfig" ];
  };
}
