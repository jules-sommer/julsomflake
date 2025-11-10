{
  lib,
  config,
  ...
}: {
  users = lib.mkIf config.services.forgejo.enable {
    users.forgejo = {
      group = "forgejo";
      isSystemUser = true;
      uid = 879;
    };
    groups.forgejo.gid = config.users.users.forgejo.uid;
  };

  # local.http = {
  #   forgejo = {
  #     domain = "git.local";
  #     port = "3000";
  #     ssl = true;
  #
  #     systemd = {
  #       createSystemUser = true;
  #       user = "forgejo";
  #       group = "forgejo";
  #     };
  #   };
  # };
}
