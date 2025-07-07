{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    user = "carlos";
    host = "nixos-alienware";
    system = "x86_64-linux";
    stateVersion = "25.05";
  in {
    nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit system stateVersion;
      };
      modules = [
        ./hosts/${host}/configuration.nix
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
