{
  lib,
  config,
  inputs,
  ...
}:
let
  # refers to the home shortcut config option
  inherit (config.local) home;
  inherit (lib) enabled enabled';
in
{
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

  options.local.home = lib.mkOption {
    description = ''
      Shorthand for accessing home-manager via a system module, this
      prevents having to type out `config.home-manager.users.jules.[...]`
      all over the flake's modules, thus hard-coding the username and
      potentially creating issues.
    '';

    type =
      with lib.types;
      coercedTo anything (v: if builtins.isList v then v else [ v ]) (listOf deferredModule);
    default = [ ];
  };

  config = {
    home-manager = {
      sharedModules =
        with inputs;
        [
        ]
        ++ home;

      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };

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
