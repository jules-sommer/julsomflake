{inputs, ...}: (_: prev: {
  inherit
    (inputs.unfree.legacyPackages.${prev.system})
    masterpdfeditor
    graphite-cli
    steam
    steam-unwrapped
    ;
})
