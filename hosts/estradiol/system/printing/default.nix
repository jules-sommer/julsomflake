{
  hardware.sane = {
    enable = true;
    openFirewall = true;
    netConf = "192.168.1.4";
  };

  services = {
    saned.enable = true;
    printing.enable = true;
  };
}
