{lib, ...}: {
  imports = [
    ./ghostty
    ./kitty
  ];

  options.local.terminal = lib.mkOption {
    type = lib.types.submodule {
      options = {};
    };
    default = {};
    description = "Per-user CLI utilities toggles.";
  };
}
