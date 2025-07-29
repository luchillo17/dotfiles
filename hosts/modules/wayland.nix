{ pkgs, ... }:
{
  # Enable Wayland support for Chrome, Slack and other Electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable Wine support for Wayland
  environment.systemPackages = with pkgs; [
    wineWowPackages.stable
  ];
}
