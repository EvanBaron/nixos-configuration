{
  pkgs,
  lib,
  ...
}:

let
  llvm = pkgs.llvmPackages_latest;
  stdenv = pkgs.stdenv;
in
{
  environment.systemPackages = with pkgs; [
    # Core Rust toolchain
    cargo
    rustc
    rust-analyzer
    rustfmt

    # C compiler and LLVM tools (needed for bindgen)
    gcc
    llvm.clang
    llvm.libclang
  ];

  # Environment variables needed for bindgen and rust-analyzer
  environment.variables = {
    LIBCLANG_PATH = "${llvm.libclang.lib}/lib";

    # Critical for bindgen to find system headers
    BINDGEN_EXTRA_CLANG_ARGS = builtins.concatStringsSep " " [
      (builtins.readFile "${stdenv.cc}/nix-support/libc-crt1-cflags")
      (builtins.readFile "${stdenv.cc}/nix-support/libc-cflags")
      (builtins.readFile "${stdenv.cc}/nix-support/cc-cflags")
      (builtins.readFile "${stdenv.cc}/nix-support/libcxx-cxxflags")
      (lib.optionalString stdenv.cc.isClang "-idirafter ${stdenv.cc.cc.lib}/lib/clang/${lib.getVersion stdenv.cc.cc}/include")
      (lib.optionalString stdenv.cc.isGNU "-isystem ${lib.getDev stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc} -isystem ${stdenv.cc.cc}/include/c++/${lib.getVersion stdenv.cc.cc}/${stdenv.hostPlatform.config} -idirafter ${stdenv.cc.cc}/lib/gcc/${stdenv.hostPlatform.config}/${lib.getVersion stdenv.cc.cc}/include")
    ];
  };
}
