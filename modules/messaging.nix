{pkgs, ...}: {
  local.home.home.packages = with pkgs; [signal-desktop-bin];
}
