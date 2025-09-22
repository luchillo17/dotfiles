{
  pkgs,
  lib,
  user,
  system,
  ...
}:

{
  # Docker setup docs: "https://wiki.nixos.org/wiki/Docker"
  # Enable Docker Engine
  virtualisation.docker = {
    enable = true;
  };

  users.users.${user}.extraGroups = lib.mkAfter [ "docker" ];

  environment.systemPackages =
    with pkgs;
    lib.mkAfter [
      docker-compose
    ];
}
