{ pkgs, ... }:
{
  home.packages = with pkgs; [
    postgresql
    postgresql.pg_config
  ];
}
