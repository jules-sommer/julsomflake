{lib, ...}: let
  inherit (lib) enabled enabled';
in {
  services = {
    printing = enabled;
    avahi = enabled' {
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP_OfficeJet_Pro_8710_7C8143";
        location = "Nancy Home";
        deviceUri = "dnssd://HP%20OfficeJet%20Pro%208710%20%5B7C8143%5D._ipp._tcp.local/?uuid=1c852a4d-b800-1f08-abcd-48ba4e7c8143";
        model = "drv:///sample.drv/deskjet.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "HP_OfficeJet_Pro_8710_7C8143";
  };
}
