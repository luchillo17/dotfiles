{ config, pkgs, ... }:
{
  programs = {
    pay-respects.enable = true;
    direnv.enable = true;
    tmux.enable = true;
    vim.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history.ignoreAllDups = true;

      initContent = ''
        eval "$(pay-respects zsh)"
      '';

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
