{
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    getModulesRecursive
    enableShellIntegrations
    foldl'
    concat
    enabled
    enabled'
    ;
in {
  imports = getModulesRecursive ./. {max-depth = 2;};
  config = {
    environment.systemPackages = with pkgs; [
      nixfmt
      nixVersions.latest
      jq
      cached-nix-shell
      nurl
      just
      gitoxide

      serie
      dust
      caligula
      fclones
      p7zip
      ncdu
      fd
      rmlint
      mediainfo
      exiftool

      (lib.lowPrio busybox)
      (lib.hiPrio gnutar)
      (lib.hiPrio uutils-coreutils-noprefix)
      (lib.hiPrio uutils-findutils)
      (lib.hiPrio uutils-diffutils)
      file
    ];
    local.home.programs.claude-code = enabled;
  };
}
