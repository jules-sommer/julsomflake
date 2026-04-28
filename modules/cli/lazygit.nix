{
  lib,
  pkgs,
  ...
}: let
  inherit (lib) enabled';
in {
  environment.systemPackages = with pkgs; [zoxide];
  local = {
    shells.aliases = {
      lg = "lazygit";
      gg = "lazygit";
    };
    home.programs.lazygit = enabled' {
      settings = {};
    };
  };
}
