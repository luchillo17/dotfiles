{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cypress
  ];

  home.sessionVariables.CYPRESS_INSTALL_BINARY = "0";
  home.sessionVariables.CYPRESS_RUN_BINARY = "${pkgs.cypress}/bin/Cypress";
}
