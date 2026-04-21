{pkgs, ...}: {
  hardware.sane = {
    enable = true;
    openFirewall = true;
    netConf = "192.168.1.4";
    extraBackends = [pkgs.sane-backends];
  };

  users.users.jules.extraGroups = ["scanner" "lp"];

  services = {
    saned.enable = true;
    printing.enable = true;
  };

  local.homePackages = with pkgs.kdePackages; [skanlite];
}
