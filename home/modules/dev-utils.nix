{ pkgs, ... }:
{
  home.packages = with pkgs; [
    btop
    fira-code
    git
    git-extras
    nix-zsh-completions
    nixfmt-rfc-style
    python312Packages.pygments

    # C / C++
    cmake
    extra-cmake-modules
    gcc
    glibc
    gnumake
    libgcc
  ];
}
