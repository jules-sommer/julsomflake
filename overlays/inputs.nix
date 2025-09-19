{inputs, ...}: (_: prev:
    with inputs; {
      nix-init = nix-init.packages.${prev.system}.default;
      neovim = nixvim.packages.${prev.system}.default;
      ghostty = ghostty.packages.${prev.system}.default;
      emoji-picker = emoji.packages.${prev.system}.script;
      zen-browser = zen-browser.packages.${prev.system}.specific;
    })
