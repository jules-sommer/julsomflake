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
  inherit (lib) enabled enabled' getModulesRecursive mkAliasOptionModule mkOption mkOptionType;
  inherit (builtins) toString;
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

    local = {
      home = lib.mkOption {
        description = ''
          Shorthand for accessing home-manager via a system module, this
          prevents having to type out `config.home-manager.users.jules.[...]`
          all over the flake's modules, thus hard-coding the username and
          potentially creating issues.
        '';

        type = lib.mkOptionType {
          name = "moduleSystemAlias";
          check = _: true;
          merge = loc:
            map (def: {
              _file = def.file;
              imports = [def.value];
            });
        };
      };

      homePackages = mkOption {
        default = [];
        type = lib.mkOptionType {
          name = "home-manager `config.home-manager.users.jules.home.packages` alias";
          check = _: true;
          merge = loc: defs:
            map (def: {
              _file = def.file;
              imports = [
                (lib.setAttrByPath ["home" "packages"] def.value)
              ];
            })
            defs;
        };
      };

      # homePackages = mkHomeAlias ["home" "packages"] ''
      #   Alias for `config.home-manager.users.jules.home.packages` @ `local.homePackages`
      # '';

      homeSessionVariables = mkOption {
        default = {};
        type = lib.mkOptionType {
          name = "home-manager `config.home-manager.users.jules.home.sessionVariables` alias";
          check = _: true;
          merge = loc: defs:
            map (def: {
              _file = def.file;
              imports = [
                (lib.setAttrByPath ["home" "sessionVariables"] def.value)
              ];
            })
            defs;
        };
      };

      # homeSessionVariables = mkHomeAlias ["home" "sessionVariables"] ''
      #   Alias for `config.home-manager.users.jules.home.sessionVariables` @ `local.homeSessionVariables`
      # '';
    };
  };

  config = {
    home = config.home-manager.users.jules;
    home-manager = {
      sharedModules = with inputs;
        [
          agenix.homeManagerModules.default
        ]
        ++ config.local.homePackages
        ++ config.local.homeSessionVariables;

      users.jules = {
        imports = config.local.home;
      };

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
