{
  lib,
  pkgs,
  ...
}: let
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
    maxHistoryLength = 1024 * 4 * 6;
    openRegistration = true;
    database = {
      createLocally = false;
      uri = "sqlite:////var/lib/atuin/atuin.db";
    };
    openFirewall = true;
  };

  systemd.services.atuin.serviceConfig = {
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    User = lib.mkForce "atuin";
    Group = lib.mkForce "atuin";
    StateDirectory = "atuin";
    StateDirectoryMode = "0750";
  };

  environment.systemPackages = with pkgs; [atuin];

  local.home.programs.atuin = mkMerge [
    enabled
    defaultShellIntegrations
    {
      daemon = enabled' {
        logLevel = "trace";
      };
    }
    {
      settings = {
        sync_address = "http://0.0.0.0:8888";
        auto_sync = true;
        filter_mode = "workspace";
        filter_mode_shell_up_key_binding = "session";
        workspaces = true;
        inline_height = 20;
        sync.records = true;
        sync_frequency = "5m";
        search_mode = "fuzzy";
        command_chaining = true;
        enter_accept = true;
        keymap_mode = "vim-normal";
        common_prefix = [
          "doas"
          "sudo"
        ];
        keymap.vim-normal = {
          ctrl-r = "cycle-filter-mode";
          alt-r = "cycle-filter-mode";
          y = "copy";
        };
        dialect = "uk";
      };
    }
  ];
}
