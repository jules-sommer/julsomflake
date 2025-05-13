{
  inputs = {
    master.url = "github:nixos/nixpkgs/master";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-24.11-small";
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

    nixvim = {
      url = "github:jules-sommer/nixvim_flake";
      inputs.zls.follows = "zls";
    };

    ghostty.url = "github:ghostty-org/ghostty";

    zls.url = "github:zigtools/zls";
    zig-overlay.url = "github:mitchellh/zig-overlay";

    emoji.url = "/home/jules/000_dev/000_nix/emoji-picker";

    nix-init.url = "github:nix-community/nix-init";

    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "unstable";
    };
  };
  outputs = {
    self,
    utils,
    ...
  } @ inputs: let
    inherit (utils.lib) eachSystem system;
    inherit (self.lib) makeChannel;

    supportedSystems = import ./flake.systems.nix;

    channels = eachSystem supportedSystems (
      system: let
        makeChannelWithSystem = makeChannel system;
      in {
        master = makeChannelWithSystem inputs.master;
        unfree = makeChannelWithSystem inputs.unfree;
        unstable = makeChannelWithSystem inputs.unstable;
        stable = makeChannelWithSystem inputs.stable;
      }
    );
  in {
    inherit channels;

    lib = import ./lib/default.nix {
      inherit (inputs.unstable) lib;
      inherit self inputs eachSystem;
    };

    nixosModules = import ./modules/default.nix;

    nixosConfigurations = let
      inherit (system) x86_64-linux aarch64-linux;
      filterChannelsForSystem = system: channels: builtins.mapAttrs (_: channelSystems: channelSystems.${system}) channels;

      sharedModules = with inputs; [
        self.nixosModules.default
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
      ];

      overlays = [
        self.overlays.default
        (_: prev: {
          inherit (channels.stable.${prev.system}.pkgs) sonic-visualiser wbg;
          inherit (channels.master.${prev.system}.pkgs) jan;
          inherit (channels.unfree.${prev.system}.pkgs) masterpdfeditor4;

          nix-init = inputs.nix-init.packages.${prev.system}.default;
          neovim = inputs.nixvim.packages.${prev.system}.default;
          ghostty = inputs.ghostty.packages.${prev.system}.default;
          emoji-picker = inputs.emoji.packages.${prev.system}.script;
        })
      ];
    in {
      estradiol = let
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
          modules =
            [
              (_: {
                _module.args = lib.mkDefault {
                  inherit
                    pkgs
                    lib
                    self
                    inputs
                    ;
                };

                nixpkgs.pkgs = pkgs;
                environment.systemPackages = with pkgs; [
                  neovim
                  nix-init
                  nurl
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
            ]
            ++ sharedModules;
        };

      progesterone = let
        systemChannels = filterChannelsForSystem aarch64-linux channels;
        defaultChannel = systemChannels.unstable;
        lib = self.lib.extendLib defaultChannel self.lib;
        pkgs = import defaultChannel._input {
          system = aarch64-linux;
          overlays =
            [
              (_: prev: {
                lib = self.lib.extendLib prev self.lib;
              })
            ]
            ++ overlays;
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
          modules =
            [
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
            ]
            ++ sharedModules;
        };
    };
    overlays = import ./overlays {inherit inputs channels;};
  };
}
