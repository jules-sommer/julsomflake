{pkgs, ...}: {
  local.home.home.packages = with pkgs.kdePackages; [
    kcalc
    isoimagewriter
    partitionmanager
  ];
}
