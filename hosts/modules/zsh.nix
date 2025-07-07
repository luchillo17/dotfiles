{ config, pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histSize = 10000;

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "vim"
        "thefuck"
      ];
      theme = "robbyrussell";
    };
  };
}
