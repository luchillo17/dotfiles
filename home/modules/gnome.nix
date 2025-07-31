{
  config,
  pkgs,
  user,
  ...
}:
{
  xdg.mimeApps.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
  };

  dconf = {
    enable = true;
    settings = {
      "org/gnome/desktop/interface" = {
        clock-format = "12h";
      };
      "org/gtk/settings/file-chooser" = {
        clock-format = "12h";
      };
      "org/gnome/settings-daemon/plugins/power" = {
        power-button-action = "hibernate";
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        accent-color = "blue";
        show-battery-percentage = true;
      };
      "org/gnome/desktop/peripherals/keyboard" = {
        numlock-state = true;
      };
    };
  };
}
