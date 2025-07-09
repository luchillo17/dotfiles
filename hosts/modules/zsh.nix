{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.defaultUserShell = pkgs.zsh;

  programs = {
    direnv.enable = true;
    thefuck.enable = true;
    tmux.enable = true;
    vim.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      histSize = 10000;

      setOptions = [
        "HIST_IGNORE_ALL_DUPS"
        "HIST_REDUCE_BLANKS"
      ];

      ohMyZsh = {
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
          "jsontools"
          "sudo"
          "systemadmin"
          "thefuck"
          "themes"
          "tmux"
          "z"
        ];
        customPkgs = with pkgs; [
          nix-zsh-completions
        ];
      };
    };
  };

  environment.variables = {
    HYPHEN_SENSITIVE = "true";
    ENABLE_CORRECTION = "true";
    COMPLETION_WAITING_DOTS = "true";
  };
}
