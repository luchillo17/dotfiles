{
  config,
  pkgs,
  stateVersion,
  user,
  ...
}:

{
  imports = [
    ./modules
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = user;
  home.homeDirectory = "/home/${user}";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = stateVersion;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    code-cursor
    gitkraken
    google-chrome
    nix-zsh-completions
    nixfmt-rfc-style
    python312Packages.pygments
  ];

  home.shell.enableZshIntegration = true;

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Carlos Esteban Lopez Jaramillo";
    userEmail = "luchillo17@gmail.com";
  };
}
