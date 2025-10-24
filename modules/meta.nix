{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption attrNames elem mkOpt;
  inherit (lib.types) str nullOr either listOf submodule attrsOf;

  users = attrNames config.users.users;
  hasUser = username: elem username users;

  hostModule = submodule {
    options = {
      ip = mkOption {
        type = str;
      };
    };
  };
in {
  options.local = {
    hosts = mkOpt (attrsOf hostModule) {} ''
      An attribute set of hosts that this flake defines and outputs.
      Can be used to provide information about the hosts.
    '';
    meta = {
      primaryUser = {
        username = mkOption {
          type = str;
          example = "jules";
          apply = username:
            if hasUser username
            then username
            else
              throw ''
                option `local.meta.primaryUser` is set to a user
                which does not exist in `config.users.users`, please set
                `config.users.users.${username} = { ... }` first.
              '';
          description = "Username for the primary user, please use the same username as you set in `config.users.users` for this user.";
        };
        full_name = mkOption {
          type = nullOr (either (listOf str) str);
          example = ["Jules" "Sommer"];
          description = "Full name of the primary user.";
        };

        email = mkOption {
          type = nullOr str;
          example = "jsomme@pm.me";
          description = "Email address associated with the primary user.";
        };
      };
    };
  };
}
