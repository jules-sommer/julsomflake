{lib, ...}: let
  inherit (lib) enabled' enabled defaultShellIntegrations mkMerge;
in {
  users.users.atuin = {
    isSystemUser = true;
    group = "atuin";
    home = "/var/lib/atuin";
    createHome = true;
    homeMode = "750";
  };

  users.groups.atuin = {};

  services.atuin = enabled' {
    host = "0.0.0.0";
    port = 8888;
    openRegistration = false;
    openFirewall = true;
  };

  local.home.programs.atuin = mkMerge [
    enabled
    defaultShellIntegrations
    {
      daemon = enabled' {
        logLevel = "info";
      };
    }
    {
      settings = {
        sync_address = "http://0.0.0.0:8888";
        auto_sync = true;
        sync = {
          records = true;
        };
        sync_frequency = "5m";
        search_mode = "fuzzy";
        command_chaining = true;
        enter_accept = true;
        keymap_mode = "vim-normal";
        common_prefix = [
          "doas"
          "sudo"
        ];
        dialect = "uk";
      };
    }
  ];

  # shells = {
  #   settings = {
  #     aliases.cat = "bat";
  #     abbreviations = {
  #       "--help" = {
  #         position = "anywhere";
  #         expansion = "--help | bat -plhelp";
  #       };
  #       "-h" = {
  #         position = "anywhere";
  #         expansion = "-h | bat -plhelp";
  #       };
  #     };
  #   };
  # };
}
