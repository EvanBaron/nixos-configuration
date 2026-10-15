{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Last revision where zotero still builds (on Firefox ESR 140); see
    # modules/home-manager/zotero.nix.
    nixpkgs-zotero.url = "github:nixos/nixpkgs/e158d9ed9b51c98974c5e66e1ba1c9e0255fecaa";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-colors = {
      url = "github:misterio77/nix-colors";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private modules and secrets that stay out of this repo.
    # After committing there: nix flake update private
    private.url = "git+file:///home/ebaron/nixos-private";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      hosts = [
        "desktop"
        "laptop"
      ];
      themes = import ./themes;

      # Function to create a nixos system configuration
      mkHost =
        host: theme:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${host}/configuration.nix
            (
              if theme != null then
                {
                  activeTheme = theme;
                }
              else
                { }
            )
          ];
        };

      # Generate configurations for each host with its default theme
      baseConfigs = lib.genAttrs hosts (host: mkHost host null);

      # Generate all combinations of host and theme
      combinatorialConfigs = lib.listToAttrs (
        lib.concatMap (
          host:
          map (theme: {
            name = "${host}-${theme}";
            value = mkHost host theme;
          }) themes
        ) hosts
      );
    in
    {
      nixosConfigurations = baseConfigs // combinatorialConfigs;
    };
}
