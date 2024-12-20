{
  inputs = {
    master.url = "github:nixos/nixpkgs/master";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    unfree.url = "github:numtide/nixpkgs-unfree?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
    };

    systems = {
      url = "path:./flake.systems.nix";
      flake = false;
    };

    utils.url = "github:numtide/flake-utils";
    stylix.url = "github:danth/stylix";

    oxalica = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "unstable";
    };

    nixvim.url = "github:jules-sommer/nixvim_flake";

    zls.url = "github:zigtools/zls";
    zig-overlay.url = "github:mitchellh/zig-overlay";

    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };
  outputs =
    {
      self,
      utils,
      ...
    }@inputs:
    let
      inherit (utils.lib) eachSystem system;
      inherit (self.lib) makeChannelEachSystem makeChannel;

      supportedSystems = import ./flake.systems.nix;

      channels = (
        eachSystem supportedSystems (
          system:
          let
            makeChannelWithSystem = makeChannel system;
          in
          {
            master = makeChannelWithSystem inputs.master;
            unfree = makeChannelWithSystem inputs.unfree;
            unstable = makeChannelWithSystem inputs.unstable;
          }
        )
      );
    in
    {
      inherit channels;

      lib = import ./lib/default.nix {
        inherit (channels.unstable) lib;
        inherit eachSystem;
      };

      nixosModules.default =
        { ... }:
        {
          imports = [
            ./modules/default.nix
          ];
        };

      nixosConfigurations =
        let
          inherit (system) x86_64-linux aarch64-linux;
          filterChannelsForSystem =
            system: channels: builtins.mapAttrs (name: channelSystems: channelSystems.${system}) channels;

          sharedModules = [
            self.nixosModules.default
            inputs.home-manager.nixosModules.home-manager
          ];
        in
        {
          estradiol =
            let
              systemChannels = filterChannelsForSystem x86_64-linux channels;
              defaultChannel = systemChannels.unstable;
              pkgs = import defaultChannel._input {
                system = x86_64-linux;
                inherit (self) overlays;
              };
              inherit (defaultChannel) lib;
            in
            lib.nixosSystem {
              system = x86_64-linux;
              modules = [
                (_: {
                  _module.args = lib.mkDefault {
                    inherit
                      pkgs
                      lib
                      self
                      inputs
                      ;
                  };

                  environment.systemPackages = [
                    inputs.nixvim.packages.${x86_64-linux}.default
                  ];
                })
                inputs.home-manager.nixosModules.home-manager
                ./modules/default.nix
                ./hosts/estradiol
              ];
            };

          progesterone =
            let
              systemChannels = filterChannelsForSystem aarch64-linux channels;
              defaultChannel = systemChannels.unstable;
              pkgs = import defaultChannel._input {
                system = aarch64-linux;
                inherit (self) overlays;
              };
              inherit (defaultChannel) lib;
            in
            lib.nixosSystem {
              system = aarch64-linux;
              modules = [
                (_: {
                  _module.args = lib.mkDefault {
                    inherit
                      pkgs
                      lib
                      self
                      inputs
                      ;
                  };
                })
                inputs.home-manager.nixosModules.home-manager
                ./modules/default.nix
                ./hosts/progesterone
              ];
            };
        };
      overlays = import ./overlays { inherit inputs channels; };
    };
}
