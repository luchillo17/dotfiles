{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop
    fira-code
    gcc
    git
    git-extras
    gnumake
    nix-zsh-completions
    nixfmt-rfc-style
    python312Packages.pygments
  ];
}
