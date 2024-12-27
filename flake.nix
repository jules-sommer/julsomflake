{
  inputs = {
    master.url = "github:nixos/nixpkgs/master";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    unfree.url = "github:numtide/nixpkgs-unfree?ref=nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "unstable";
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
      inherit (self.lib) makeChannel;

      supportedSystems = import ./flake.systems.nix;

      channels = eachSystem supportedSystems (
        system:
        let
          makeChannelWithSystem = makeChannel system;
        in
        {
          master = makeChannelWithSystem inputs.master;
          unfree = makeChannelWithSystem inputs.unfree;
          unstable = makeChannelWithSystem inputs.unstable;
        }
      );
    in
    {
      inherit channels;

      lib = import ./lib/default.nix {
        inherit (inputs.unstable) lib;
        inherit self inputs eachSystem;
      };

      nixosModules = import ./modules/default.nix;

      nixosConfigurations =
        let
          inherit (system) x86_64-linux aarch64-linux;
          filterChannelsForSystem =
            system: channels: builtins.mapAttrs (name: channelSystems: channelSystems.${system}) channels;

          sharedModules = with inputs; [
            self.nixosModules.default
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ];

          overlays = [
            self.overlays.default
            (final: prev: { neovim = inputs.nixvim.packages.${prev.system}.default; })
          ];

        in
        {
          estradiol =
            let
              systemChannels = filterChannelsForSystem x86_64-linux channels;
              defaultChannel = systemChannels.unstable;
              lib = self.lib.extendLib defaultChannel self.lib;

              pkgs = import defaultChannel._input {
                system = x86_64-linux;
                inherit overlays;
              };
            in
            lib.nixosSystem {
              system = x86_64-linux;
              specialArgs = {
                inherit
                  pkgs
                  lib
                  self
                  inputs
                  ;
              };
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
                inputs.stylix.nixosModules.stylix
                self.nixosModules.stylix
                ./hosts/estradiol
                (_: {
                  home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    backupFileExtension = "backup";
                    users.jules = import ./hosts/estradiol/home/default.nix;
                  };
                })
              ] ++ sharedModules;
            };

          progesterone =
            let
              systemChannels = filterChannelsForSystem aarch64-linux channels;
              defaultChannel = systemChannels.unstable;
              lib = self.lib.extendLib defaultChannel self.lib;
              pkgs = import defaultChannel._input {
                system = aarch64-linux;
                overlays = [
                  (_: prev: {
                    lib = self.lib.extendLib prev self.lib;
                  })

                ] ++ overlays;
              };
            in
            lib.nixosSystem {
              system = aarch64-linux;
              specialArgs = {
                inherit
                  pkgs
                  lib
                  self
                  inputs
                  ;
              };
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
                ./hosts/progesterone
              ] ++ sharedModules;
            };
        };
      overlays = import ./overlays { inherit inputs channels; };
    };
}
