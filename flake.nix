{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/release-25.05";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      sops-nix,
      home-manager,
      ...
    }:
    let
      user = "carlos";
      host = "nixos-alienware";
      wslHost = "nixos-wsl-z390";
      system = "x86_64-linux";
      stateVersion = "25.05";
    in
    {
      nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            user
            system
            stateVersion
            ;
        };
        modules = [
          ./hosts/${host}/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      nixosConfigurations.${wslHost} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            user
            system
            stateVersion
            ;
        };
        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/${wslHost}/configuration.nix
          sops-nix.nixosModules.sops
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
