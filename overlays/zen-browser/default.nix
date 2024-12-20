{ inputs, ... }:
(_: prev: {
  zen-browser = inputs.zen-browser.packages.${prev.system}.specific;
})
