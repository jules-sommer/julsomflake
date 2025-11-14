{
  pkgs,
  self,
  lib,
  config,
  inputs,
  ...
}: let
  # refers to the home shortcut config option
  inherit (config.local) home;
  inherit (lib) enabled enabled' getModulesRecursive;
  inherit (builtins) substring toString;
in {
  imports =
    getModulesRecursive ./. {max-depth = 1;};

  options = {
    home = lib.mkOption {
      type = lib.types.attrs;
      description = ''
        Shortcut to the fully evaluated home-manager config
        for user `jules`.
      '';
      readOnly = true;
    };

    local.home = lib.mkOption {
      description = ''
        Shorthand for accessing home-manager via a system module, this
        prevents having to type out `config.home-manager.users.jules.[...]`
        all over the flake's modules, thus hard-coding the username and
        potentially creating issues.
      '';

      type = lib.mkOptionType {
        name = "home-manager module";
        check = _: true;
        merge = loc:
          map (def: {
            _file = def.file;
            imports = [def.value];
          });
      };
    };
  };

  config = {
    home = config.home-manager.users.jules;
    home-manager = {
      sharedModules = with inputs;
        [
          agenix.homeManagerModules.default
        ]
        ++ home;

      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup-${toString self.lastModified}";
    };

    environment.systemPackages = [pkgs.git];

    local.home = {
      manual = {
        json = enabled;
        html = enabled;
        manpages = enabled;
      };
      home = {
        enableNixpkgsReleaseCheck = true;
        preferXdgDirectories = true;
        extraOutputsToInstall = [
          "doc"
          "info"
          "devdoc"
        ];
      };

      services.home-manager = {
        autoExpire = enabled' {
          timestamp = "-7 days";
          store = {
            cleanup = true;
            options = "--delete-older-than 14d";
          };
        };
        autoUpgrade = enabled' {
          frequency = "weekly";
        };
      };
    };
  };
}
