{...}: {
  imports = [
    ./registry.nix
  ];

  nix = {
    settings = {
      download-buffer-size = 524288000;
      cores = 12;
      warn-dirty = false;
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      substituters = [
        "https://hyprland.cachix.org"
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      http-connections = 50;
      log-lines = 50;
      sandbox = "relaxed";

      allowed-users = ["@users"];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}
