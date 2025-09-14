{
  outputs = {
    self,
    utils,
    ...
  } @ inputs: let
    inherit (utils.lib) eachSystem system;
    inherit (self.lib) makeChannel;
    helpers = inputs.helpers.lib;

    supportedSystems = import ./flake.systems.nix;

    channels = eachSystem supportedSystems (
      system: let
        makeChannelWithSystem = makeChannel system;
      in {
        unstable = makeChannelWithSystem inputs.nixpkgs;
        unfree = makeChannelWithSystem inputs.unfree;
      }
    );
  in rec {
    inherit channels;

    lib = import ./lib/default.nix {
      inherit (inputs.nixpkgs) lib;
      inherit self inputs eachSystem;
    };

    nixosConfigurations = let
      inherit (system) x86_64-linux aarch64-linux;
      filterChannelsForSystem = system: channels: builtins.mapAttrs (_: channelSystems: channelSystems.${system}) channels;

      sharedModules = with inputs; [
        home-manager.nixosModules.home-manager
        niri-flake.nixosModules.niri
        sops-nix.nixosModules.sops
      ];

      overlays = [
        self.overlays.default
        (_: prev: {
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
              helpers
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
              ./hosts/estradiol
              ./modules
              ./modules/system/stylix
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

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nq.url = "github:diniamo/nq";
    unfree.url = "github:numtide/nixpkgs-unfree?ref=nixos-unstable";

    utils.url = "github:numtide/flake-utils";
    helpers.url = "/home/jules/000_dev/000_nix/flake-helpers";
    stylix.url = "github:danth/stylix";

    niri = {
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.niri-unstable.follows = "niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = "/home/jules/000_dev/000_nix/nvf_julesvim";
    ghostty.url = "github:ghostty-org/ghostty";
    emoji.url = "/home/jules/000_dev/000_nix/emoji-picker";
    nix-init.url = "github:nix-community/nix-init";
    zen-browser = {
      url = "github:MarceColl/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
