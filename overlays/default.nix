{
  self,
  inputs,
  lib,
}: let
  inherit (lib) composeManyExtensions;
in {
  default = final: prev: {};
  stable = composeManyExtensions [
    (_: prev: {
      inherit (inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}) protonvpn-gui electron;
    })
  ];
  unfree = composeManyExtensions [
    (_: prev: {
      inherit (inputs.unfree.legacyPackages.${prev.stdenv.hostPlatform.system}) zsh-abbr masterpdfeditor4 masterpdfeditor claude-code libsciter;
    })
  ];

  # this overlay is exactly the same as the one provided by sodiboo/niri-flake
  # with the one exception of it's handling of cargo tests. Basically, it defaults
  # to disabling the tests which frequently run into open FD limits.
  niri = final: prev: {
    niri = inputs.niri.packages.${prev.stdenv.hostPlatform.system}.default.overrideAttrs {doCheck = false;};
  };

  julespkgs = _: prev: {
    julespkgs = inputs.julespkgs.packages.${prev.stdenv.hostPlatform.system} // self.packages.${prev.stdenv.hostPlatform.system};
  };

  from_inputs = composeManyExtensions (
    with inputs; [
      (_: prev: {
        helium = helium.defaultPackage.${prev.stdenv.hostPlatform.system};
        neovim = neovim.packages.${prev.stdenv.hostPlatform.system}.default;
        zen-browser = julespkgs.packages.${prev.stdenv.hostPlatform.system}.zen-browser__default;
        jan = julespkgs.packages.${prev.stdenv.hostPlatform.system}.jan;
      })
    ]
  );
}
