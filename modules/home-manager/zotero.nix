# Zotero 10.0.4 in current nixpkgs is built on Firefox ESR 153, but it only
# supports ESR 140: its build script patches a dozen Firefox internals that
# moved in 153, so the build aborts. Take zotero from a pinned nixpkgs where it
# still builds (and is in the binary cache). Drop this, and the
# nixpkgs-zotero flake input, once nixpkgs' zotero builds again.
{ pkgs, inputs, ... }:

let
  zotero = inputs.nixpkgs-zotero.legacyPackages.${pkgs.stdenv.hostPlatform.system}.zotero;
in
{
  home.packages = [
    # The session's LD_LIBRARY_PATH (PipeWire's JACK libs) points at libraries
    # built against the newer glibc, which the pinned zotero can't load.
    (pkgs.symlinkJoin {
      name = "zotero-${zotero.version}";
      paths = [ zotero ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/zotero --unset LD_LIBRARY_PATH
      '';
    })
  ];
}
