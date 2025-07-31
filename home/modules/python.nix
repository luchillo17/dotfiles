{ pkgs, ... }:
{
  programs.poetry = {
    enable = true;
  };

  home.packages = with pkgs; [
    python311
    python312Packages.python-lsp-server
  ];
}
