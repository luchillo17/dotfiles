{ config, pkgs, ... }:
{
  programs = {
    direnv.enable = true;
    thefuck.enable = true;
    tmux.enable = true;
    vim.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history.ignoreAllDups = true;

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "aliases"
          "bgnotify"
          "colorize"
          "command-not-found"
          "common-aliases"
          "direnv"
          "dotenv"
          "git-extras"
          "git-flow"
          "git"
          "gitfast"
          "helm"
          "jsontools"
          "kubectl"
          "microk8s"
          "npm"
          "pm2"
          "sudo"
          "systemadmin"
          "thefuck"
          "themes"
          "tmux"
          "vscode"
          "z"
        ];
      };
    };
  };

  home.sessionVariables.HYPHEN_SENSITIVE = "true";
  home.sessionVariables.ENABLE_CORRECTION = "true";
  home.sessionVariables.COMPLETION_WAITING_DOTS = "true";
}
