{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  # refers to the home shortcut config option
  inherit (config.local) home;
  inherit (lib) enabled enabled';
in {
  imports = [
    ./audio
    ./cli
    ./doas
    ./documents+pdf
    ./evremap
    ./fonts
    ./kmail
    ./nix
    ./shells
    ./ssh
    ./stylix
    ./terminal
    ./users
    ./wayland
    ./xanmod_kernel
  ];
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
        ]
        ++ home;

      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };

    environment.systemPackages = [pkgs.git];
    local = {
      config_aliases = [
        {
          # this alias maps `config.homeDirectory` to point to `config.home-manager.users.jules.home.homeDirectory`.
          source = ["homeDirectory"];
          dest = ["home-manager" "users" "jules" "home" "homeDirectory"];
        }
      ];

      home = {
        manual = {
          json = enabled;
          html = enabled;
          manpages = enabled;
        };
        home.extraOutputsToInstall = [
          "doc"
          "info"
          "devdoc"
        ];

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
  };
}
