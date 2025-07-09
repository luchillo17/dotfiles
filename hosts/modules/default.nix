{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./prisma.nix
    ./zsh.nix
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    bintools
    git
    git-extras
    home-manager
    nixfmt-rfc-style
    python312Packages.pygments
    wget
  ];
  environment.variables.EDITOR = "vim";
}
