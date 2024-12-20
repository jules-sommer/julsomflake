{ lib, eachSystem }:
rec {
  makeChannel = system: input: {
    inherit system;
    inherit (input) lib;
    inherit (input.lib) version;
    _input = input;
    pkgs = input.legacyPackages.${system};
  };
}
