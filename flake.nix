{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      compose2nix,
      ...
    }:
    let
      user = "carlos";
      host = "nixos-alienware";
      wslHost = "nixos-wsl-z390";
      system = "x86_64-linux";
      stateVersion = "25.11";
    in
    {
      nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            user
            system
            stateVersion
            compose2nix
            ;
        };
        modules = [
          ./hosts/${host}/configuration.nix
        ];
      };

      nixosConfigurations.${wslHost} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit system stateVersion compose2nix;
        };
        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/${wslHost}/configuration.nix
        ];
      };

      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = {
          inherit inputs stateVersion user;
        };
        modules = [ ./home ];
      };
    };
}
