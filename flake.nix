{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs1.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-nvim = {
      url = "github:nixos/nixpkgs?rev=c9d8364bfd32485312562fe6ee21859a78b86625";
      flake = false;
    };

    nixpkgs-hypr = {
      url = "github:nixos/nixpkgs?rev=b5aa0fbd538984f6e3d201be0005b4463d8b09f8";
      flake = false;
    };

    hyprland.url = "github:hyprwm/Hyprland";

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/master";

    # nvimdots.url = "github:ayamir/nvimdots";
    # nvimdots.url = "github:frsfallingsand/nvimdots";
    nvimdots.url = "github:frsfallingsand/nvimdots?ref=main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      # url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-nvim,
      nixpkgs1,
      hyprland,
      home-manager,
      quickshell,
      nvimdots,
      # chaotic,
      nix-cachyos-kernel,
      nixpkgs-hypr,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # 自动扫描 modules 目录下的所有 .nix 文件
      #configDir = ./modules;
      #generatedModules = builtins.map (file: configDir + "/${file}")
      #  (builtins.filter (file: nixpkgs.lib.hasSuffix ".nix" file)
      #    (builtins.attrNames (builtins.readDir configDir)));

      #lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
      };
      pkgs-nvim = import nixpkgs-nvim {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-lutris = import nixpkgs1 {
        inherit system;
        config.allowUnfree = true;
        # overlays = [
        # Skipping tests while upstream sorts it out, revert once
        # Hydra consistently builds openldap green.
        # (final: prev: {
        # openldap = prev.openldap.overrideAttrs (_: {
        #  doCheck = false;
        # });
        # })
        # ];
      };
      pkgs-hypr = import nixpkgs-hypr {
        inherit system;
        config.allowUnfree = true;
      };
      nvim = pkgs-nvim.neovim-unwrapped;
      lutr = pkgs-lutris.lutris;
      dmsNixOSModule = inputs.dms.nixosModules.default;
      nvimdotsHMModule = nvimdots.homeManagerModules.default;
      quickshellPkg = quickshell.packages.${system}.quickshell;
      dmsDefaultPkg = inputs.dms.packages.${system}.default;
      nHMM = inputs.noctalia.homeModules.default;
      nP = inputs.noctalia.packages.${system}.default;
      cachy = inputs.nix-cachyos-kernel.packages.${system}.linux-cachyos-bore-lto-x86_64-v3;
      hypr = pkgs-hypr.hyprland;
      hmSpecialArgs = {
        inherit
          nvimdotsHMModule
          quickshell
          nHMM
          nvim
          hyprland
          hypr
          ;
      };

    in
    {
      nixosConfigurations.qqxnkrut = nixpkgs.lib.nixosSystem {
        inherit system;
        #specialArgs = { inherit inputs quickshell; };
        specialArgs = {
          inherit
            quickshell
            dmsNixOSModule
            nvimdotsHMModule
            quickshellPkg
            dmsDefaultPkg
            nP
            nvim
            lutr
            hyprland
            cachy
            hypr
            ;
        };
        modules = [
          ./configuration.nix
          inputs.home-manager.nixosModules.default
          home-manager.nixosModules.home-manager
          # chaotic.nixosModules.default
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = hmSpecialArgs;
              users.fgsd = ./home/fgsd.nix;
              # _module.args.quickshell = inputs.quickshell;
            };
          }
          #] ++ generatedModules;
        ];
      };
    };
}
