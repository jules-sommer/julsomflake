{channels, ...}: _: prev: {
  inherit
    (channels.unfree.${prev.system}.pkgs)
    masterpdfeditor
    graphite-cli
    steam
    steam-unwrapped
    ;
}
