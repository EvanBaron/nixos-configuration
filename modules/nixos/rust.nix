# Rust development environment configuration
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core Rust toolchain
    cargo
    rustc
    rust-analyzer
    rustfmt

    # C compiler (needed for some Rust crates with C dependencies)
    gcc
  ];
}
