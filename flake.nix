{
  outputs = {
    self,
    utils,
    ...
  } @ inputs: let
    inherit (utils.lib) eachDefaultSystemPassThrough eachDefaultSystem;
    inherit (inputs.nixpkgs.lib) importJSON;
    systems = utils.lib.system;
    defaultOverlays = with self.overlays; [
      default
      from_inputs
      unfree
      stable
      julespkgs
      niri
    ];

    npins = (importJSON ./npins/sources.json).pins;

    src = ./.; # flake source passed to modules via _module.args

    makePkgs = system:
      import inputs.nixpkgs {
        inherit system;
        overlays = defaultOverlays ++ [];
      };
  in
    eachDefaultSystemPassThrough (
      system: let
        helpers = inputs.helpers.lib;

        _module.args = {
          inherit
            helpers
            lib
            self
            inputs
            src
            ;
          packages = self.packages.${system};
        };

        pkgs = makePkgs system;
        inherit (self) lib;
        inherit (inputs.nixpkgs.lib) nixosSystem;

        specialArgs = _module.args;
      in {
        packages.${system} = import ./packages {
          inherit self inputs pkgs npins;
          inherit (self) lib;
        };

        nixosConfigurations = let
          sharedModules = with inputs; [
            home-manager.nixosModules.home-manager
            niri-flake.nixosModules.niri
            agenix.nixosModules.default
          ];
        in {
          estradiol = nixosSystem {
            system = systems.x86_64-linux;
            inherit specialArgs;
            modules =
              [
                (_: {
                  inherit _module;
                  nixpkgs.overlays = defaultOverlays;
                })
                inputs.stylix.nixosModules.stylix
                ./modules/default.nix
                ./hosts/estradiol
                ./modules/stylix
              ]
              ++ sharedModules;
          };

          progesterone = nixosSystem {
            system = systems.aarch64-linux;
            inherit specialArgs;
            modules =
              [
                ./hosts/progesterone
              ]
              ++ sharedModules;
          };
        };

        lib = import ./lib {
          inherit inputs;
        };

        overlays = import ./overlays {
          inherit inputs;
          inherit self;
          inherit (inputs.nixpkgs) lib;
        };
      }
    )
    // eachDefaultSystem (
      system: let
        pkgs = makePkgs system;
      in {
        devShells = import ./devShells.nix {inherit pkgs inputs system;};
      }
    );

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11-small";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium = {
      url = "github:FKouhai/helium2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };

    unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helpers = {
      url = "/home/jules/000_dev/000_nix/flake-helpers";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-flake = {
      url = "git+file:///home/jules/000_dev/000_nix/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    julespkgs = {
      url = "git+https://git.nixfox.ca/Jules/julsompkgs";
      # url = "git+https://codeberg.org/julesomgirl/julsompkgs.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim = {
      url = "git+https://git.nixfox.ca/Jules/julsomvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig = {
      url = "github:silversquirl/zig-flake/compat";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zls = {
      url = "github:zigtools/zls";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        zig-overlay.follows = "zig";
      };
    };
  };
}
