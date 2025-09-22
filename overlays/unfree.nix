{inputs, ...}: (_: prev: {
  inherit
    (inputs.unfree.legacyPackages.${prev.system})
    masterpdfeditor
    masterpdfeditor4
    graphite-cli
    steam
    steam-unwrapped
    ;
})
