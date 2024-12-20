{ channels, ... }:
_: _: {
  inherit (channels.unfree.pkgs)
    masterpdfeditor
    graphite-cli
    steam
    steam-unwrapped
    ;
}
