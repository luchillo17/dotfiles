{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    gpu-screen-recorder-gtk # GUI app
  ];
}
