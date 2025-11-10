{
  lib,
  config,
  ...
}: let
  inherit
    (lib)
    mkAliasOptionModule
    types
    mkOption
    mkOpt
    mkOptWithExample
    mapAttrs
    isAttrs
    isString
    ;
  inherit
    (types)
    submodule
    attrsOf
    str
    nullOr
    either
    bool
    listOf
    ;

  abbrModule = submodule {
    options = {
      expansion = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          The command expanded by an abbreviation.
        '';
      };

      position = mkOption {
        type = nullOr str;
        default = null;
        example = "anywhere";
        description = ''
          If the position is "command", the abbreviation expands only if
          the position is a command. If it is "anywhere", the abbreviation
          expands anywhere.
        '';
      };

      regex = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          The regular expression pattern matched instead of the literal name.
        '';
      };

      command = mkOption {
        type = nullOr (either str (listOf str));
        default = null;
        description = ''
          Specifies the command(s) for which the abbreviation should expand. If
          set, the abbreviation will only expand when used as an argument to
          the given command(s).
        '';
      };

      setCursor = mkOption {
        type = either bool str;
        default = false;
        description = ''
          The marker indicates the position of the cursor when the abbreviation
          is expanded. When setCursor is true, the marker is set with a default
          value of "%".
        '';
      };

      function = mkOption {
        type = nullOr str;
        default = null;
        description = ''
          The fish function expanded instead of a literal string.
        '';
      };
    };
  };

  aliases = config.local.shells.settings.aliases;
  abbrs = config.local.shells.settings.abbreviations;

  strOnlyAbbrs = mapAttrs (abbr: expansion: (
    if isString expansion
    then expansion
    else if isAttrs expansion && expansion ? "expansion"
    then expansion.expansion
    else null
  ));
in {
  imports = [
    (mkAliasOptionModule ["local" "shells" "aliases"] ["local" "shells" "settings" "aliases"])
    (mkAliasOptionModule ["local" "shells" "abbreviations"] ["local" "shells" "settings" "abbreviations"])
  ];

  options.local.shells.settings = {
    abbreviations = mkOpt (attrsOf (either str abbrModule)) {} ''
      An attribute set that maps aliases (the top level attribute names
      in this option) to abbreviations. Abbreviations are expanded with
      the longer phrase after they are entered.
    '';

    aliases =
      mkOptWithExample (attrsOf str) {}
      {
        g = "git";
        "..." = "cd ../..";
      }
      ''
        An attribute set that maps aliases (the top level attribute names
        in this option) to command strings or directly to build outputs.
      '';
  };

  config.local.home = {
    programs.zsh = {
      zsh-abbr.abbreviations =
        abbrs
        |> strOnlyAbbrs;
      shellAliases = aliases;
    };
    programs.fish = {
      shellAbbrs = abbrs;
      shellAliases = aliases;
    };
  };
}
#
# old aliases/abbrs
#
# shellAliases = foldl' recursiveUpdate {} [
#   {
#     # screenshot = "grim -g \"$(slurp -d)\" - | tee ~/060_media/005_screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy -t image/png";
#     targz = "tar -czvf";
#     cat = "bat";
#   }
#   (mkIf config.security.doas.enable {
#     sudo = "doas";
#     sudoedit = "doas rnano";
#   })
#   (mkIf config.home.programs.fastfetch.enable {
#     ff = "fastfetch";
#   })
# ];
#
# shellAbbrs = {
#   lst = "ls -TL2";
#   br = "broot -hips";
#   brw = "broot -hips";
#
# };

