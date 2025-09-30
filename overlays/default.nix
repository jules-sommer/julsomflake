{
  packages,
  inputs,
  lib,
}:
let
  inherit (lib) composeManyExtensions;
in
{
  default = _: prev: { };
  unfree = composeManyExtensions [
    (_: prev: {
      inherit (inputs.unfree.legacyPackages.${prev.system}) zsh-abbr masterpdfeditor4 masterpdfeditor;
    })
  ];

  disable_niri_tests =
    final: prev:
    let
      disableChecks =
        drv:
        drv.overrideAttrs (old: {
          doCheck = false;
          doInstallCheck = false;
          checkPhase = "";
          installCheckPhase = "";
          preCheck = (old.preCheck or "") + ''
            export RUST_TEST_THREADS=1
            export CARGO_BUILD_JOBS=1
          '';
        });
    in
    (
      {
        niri = disableChecks prev.niri;
      }
      // (
        if builtins.hasAttr "niri-unwrapped" prev then
          {
            "niri-unwrapped" = disableChecks prev."niri-unwrapped";
          }
        else
          { }
      )
    );

  julespkgs = _: prev: {
    julespkgs = packages.${prev.system};
  };

  from_inputs = composeManyExtensions (
    with inputs;
    [
      niri.overlays.niri
      ghostty.overlays.default
      (_: prev: {
        neovim = neovim.packages.${prev.system}.default;
        nix-init = nix-init.packages.${prev.system}.default;
        zen-browser = julespkgs.packages.${prev.system}.zen-browser__default;
        jan = julespkgs.packages.${prev.system}.jan;
      })
    ]
  );
}
