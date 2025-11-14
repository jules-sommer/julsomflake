{lib, ...}: let
  inherit
    (lib)
    enabled'
    ;
in {
  config = {
    users.users.seat = {
      isSystemUser = true;
      group = "seat";
      description = "Seat management daemon user";
    };

    services.seatd = enabled' {
      user = "seat";
      group = "seat";
    };

    users.users.jules.extraGroups = ["seat"];
  };
}
