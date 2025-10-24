{
  outputs = {
    self,
    utils,
    ...
  } @ inputs: let
    inherit (utils.lib) eachDefaultSystemPassThrough eachDefaultSystem;
    inherit (self) overlays;
    systems = utils.lib.system;
    defaultOverlays = with overlays; [
      default
      from_inputs
      unfree
      julespkgs
      niri
    ];

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
          inherit self inputs pkgs;
          inherit (inputs.nixpkgs) lib;
        };
        nixosConfigurations = let
          sharedModules = with inputs; [
            home-manager.nixosModules.home-manager
            niri.nixosModules.niri
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

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium.url = "github:FKouhai/helium2nix/main";

    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        darwin.follows = "";
      };
    };

    unfree.url = "github:numtide/nixpkgs-unfree?ref=nixos-unstable";

    utils.url = "github:numtide/flake-utils";
    helpers.url = "/home/jules/000_dev/000_nix/flake-helpers";
    stylix.url = "github:danth/stylix";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    julespkgs = {
      url = "git+file:///home/jules/000_dev/000_nix/packages";
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

    neovim = {
      # url = "git+https://git.nixfox.ca/Jules/neovim-flake.git";
      url = "git+file:///home/jules/000_dev/000_nix/julsomvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";
  };
}
