{ pkgs, ... }:
{
  programs.poetry = {
    enable = true;
    package = pkgs.writeShellScriptBin "poetry" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.poetry}/bin/poetry "$@"
    '';
  };

  home.packages = with pkgs; [
    (pkgs.writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.python311}/bin/python "$@"
    '')
    python311Packages.python-lsp-server
  ];
}
