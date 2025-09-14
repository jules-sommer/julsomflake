{helpers, ...}: let
  inherit (helpers) enabled';
in {
  services.openssh = enabled' {
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };
}
