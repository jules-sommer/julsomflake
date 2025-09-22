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
    okular = mkEnableOpt "Enable Okular PDF editor.";
    masterpdf = mkEnableOpt "Enable Master PDF Editor, supports XFA forms.";
    libreoffice = mkEnableOpt "Enable LibreOffice.";
  };

  config = mkIf (cfg.okular.enable || cfg.libreoffice.enable) {
    environment.systemPackages = with pkgs; [
      (mkIf cfg.okular.enable kdePackages.okular)
      (mkIf cfg.libreoffice.enable libreoffice)
      (mkIf cfg.masterpdf.enable masterpdfeditor)
    ];
  };
}
