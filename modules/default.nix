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
    ./cli
    ./evremap
    ./nix
    ./shells
    ./stylix
    ./terminal
    ./wayland
    ./aliases.nix
    ./audio.nix
    ./doas.nix
    ./docs_pdf.nix
    ./fonts.nix
    ./kmail.nix
    ./nh.nix
    ./secrets.nix
    ./ssh.nix
    ./users.nix
    ./xanmod_kernal.nix
    ./printers.nix
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

    local.home = {
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
}
