# Julsomflake Roadmap

## Planned features

1. ~~Update screenshot script to use [Satty](https://github.com/Satty-org/Satty) for annotating captured screenshots.~~
2. Switch to a more modern and maintained flake for niri configuration, or alternatively if such a flake does not exist, simply write the .kdl config in our own flake to `~/.config/niri/config.kdl`.
    - This is kind of annoying, might just switch to using kdl directly to configure. Seems like less of a pain. :/ 
3.   

## TODO
1. Fix issue where full sentences were passed to `lib.mkEnableOption` description property, which actually already builds the sentence for you given it's always some variation of `Whether to enable <...>.`, and so we ended up with every option description reading like: `Whether to enable Whether to enable <...>.`
2. Maybe have a module where you can set the default user's email and various other pieces of information that get used all over the place so that I don't have to grep the entire flake when I change my email or the like. 

