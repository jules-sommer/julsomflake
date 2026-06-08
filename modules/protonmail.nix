{pkgs, ...}: {
  local.home.services = {
    gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
    protonmail-bridge = {
      enable = true;
      extraPackages = with pkgs; [gnome-keyring libsecret];
    };
  };
}
