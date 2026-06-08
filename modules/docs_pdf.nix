{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOpt
    mkIf
    ;
  cfg = config.local.programs;
in {
  options.local.programs = {
    okular = mkEnableOpt "okular";
    masterpdf = mkEnableOpt "masterpdfeditor";
    libreoffice = mkEnableOpt "libreoffice";
  };

  config = mkIf (cfg.okular.enable || cfg.libreoffice.enable) {
    environment.systemPackages = with pkgs; [
      (mkIf cfg.okular.enable kdePackages.okular)
      (mkIf cfg.libreoffice.enable libreoffice)
      (mkIf cfg.masterpdf.enable masterpdfeditor)
    ];
  };
}
