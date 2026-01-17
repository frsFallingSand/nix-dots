{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nvimdots.url = "github:ayamir/nvimdots";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
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

  outputs = { self, nixpkgs, home-manager, quickshell, ... }@inputs: 
  let
    system = "x86_64-linux";
    # 自动扫描 modules 目录下的所有 .nix 文件
    configDir = ./modules;
    generatedModules = builtins.map (file: configDir + "/${file}") 
      (builtins.filter (file: nixpkgs.lib.hasSuffix ".nix" file) 
        (builtins.attrNames (builtins.readDir configDir)));
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs quickshell; };
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.default
      ] ++ generatedModules; 
    };
  };
}
