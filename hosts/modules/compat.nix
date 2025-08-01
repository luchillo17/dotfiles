{
  config,
  lib,
  pkgs,
  ...
}:
{
  # https://wiki.nixos.org/wiki/Python#Using_nix-ld
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld;
    libraries = with pkgs; [
      acl
      attr
      bzip2
      curl
      glib
      libGL
      libsodium
      libssh
      libxml2
      openssl
      stdenv.cc.cc
      systemd
      util-linux
      xz
      zlib
      zstd
    ];
  };

  # https://github.com/nix-community/nix-ld?tab=readme-ov-file#my-pythonnodejsrubyinterpreter-libraries-do-not-find-the-libraries-configured-by-nix-ld
  environment.systemPackages = lib.mkAfter [
    (pkgs.writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.python3}/bin/python "$@"
    '')
  ];

  # Ensure /bin/bash exists, since some scripts expect it to be there
  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
      #!/bin/sh
      # This script creates a symlink to the bash binary in /bin
      # to ensure compatibility with scripts that expect bash to be in /bin/bash
      ln -sf /bin/sh /bin/bash
    '';
  };

  # 32-bit graphics support, for Steam/etc.
  hardware.graphics.enable32Bit = true;
}
