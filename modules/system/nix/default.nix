{
  ...
}:
{
  nix = {
    settings =
      let
        users = [
          "root"
          "jules"
        ];
      in
      {
        cores = 12;
        warn-dirty = false;
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";
        # Deduplicate and optimize nix store
        auto-optimise-store = true;
        # Use binary caches
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

        trusted-users = users;
        allowed-users = users;
      };
    gc = {
      automatic = false;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };
}
