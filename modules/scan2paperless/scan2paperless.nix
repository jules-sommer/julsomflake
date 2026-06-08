{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.services.scan2paperless = {
    enable = mkEnableOption "scan2paperless";

    host = mkOption {type = types.str;};
    user = mkOption {type = types.str;};

    passwordFile = mkOption {
      type = types.path;
      description = "File containing the paperless password. Compatible with agenix secrets.";
    };

    device = mkOption {
      type = types.str;
      default = "airscan:e1:HP OfficeJet Pro 8710 [7C8143]";
    };
  };
}
