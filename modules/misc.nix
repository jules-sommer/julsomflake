{pkgs, ...}: {
  local.home.home.packages = with pkgs.kdePackages; [
    dolphin
    kcalc
    isoimagewriter
    partitionmanager
  ];
}
