{
  outputs = {
    self,
    utils,
    ...
  } @ inputs: let
    inherit (utils.lib) eachDefaultSystemPassThrough eachDefaultSystem;
    systems = utils.lib.system;
    inherit (self) overlays;
    supportedSystems = import ./flake.systems.nix;
    makePkgs = system:
      import inputs.nixpkgs {
        inherit system;
        overlays = [self.overlays.default];
      };
  in
    eachDefaultSystemPassThrough (system: let
      inherit (self.lib) makeChannel;
      helpers = inputs.helpers.lib;
      lib = self.lib.extendLibMany inputs.nixpkgs [helpers];

      module.args = {
        inherit helpers pkgs lib self inputs;
      };

      pkgs = makePkgs system;

      specialArgs = module.args;
    in {
      nixosConfigurations = let
        sharedModules = with inputs; [
          home-manager.nixosModules.home-manager
          niri-flake.nixosModules.niri
          sops-nix.nixosModules.sops
        ];

        overlays = [
          self.overlays.default
          (_: prev: {
            inherit (inputs.unfree.${prev.system}.pkgs) masterpdfeditor4;
          })
        ];
      in {
        estradiol = let
          lib = self.lib.extendLibMany [helpers];
        in
          lib.nixosSystem {
            system = systems.x86_64-linux;
            specialArgs = module.args;
            modules =
              [
                (_: {
                  inherit (module) args;

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

        progesterone = lib.nixosSystem {
          system = systems.aarch64-linux;
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
                  inputs.nixvim.packages.${system}.default
                ];
              })
              ./hosts/progesterone
            ]
            ++ sharedModules;
        };
      };

      lib = import ./lib/default.nix {
        inherit (inputs.nixpkgs) lib;
      };

      overlays = {
        default = import ./overlays {
          inherit inputs;
          inherit (inputs.nixpkgs) lib;
          inherit (inputs.nixpkgs.legacyPackages.${system}) callPackage;
        };
      };
    })
    // eachDefaultSystem (system: let
      pkgs = makePkgs system;
    in {
      devShells = pkgs.callPackage ./devShells.nix {inherit pkgs;};
    });

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
