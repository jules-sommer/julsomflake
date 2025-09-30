{
  outputs =
    {
      self,
      utils,
      ...
    }@inputs:
    let
      inherit (utils.lib) eachDefaultSystemPassThrough eachDefaultSystem;
      inherit (self) overlays;
      systems = utils.lib.system;
      defaultOverlays = with overlays; [
        default
        from_inputs
        unfree
        disable_niri_tests
        julespkgs
      ];
      makePkgs =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = defaultOverlays ++ [ ];
        };
    in
    eachDefaultSystemPassThrough (
      system:
      let
        helpers = inputs.helpers.lib;

        _module.args = {
          inherit
            helpers
            lib
            self
            inputs
            ;
          packages = self.packages.${system};
        };

        pkgs = makePkgs system;
        lib = self.lib.extendLibMany pkgs.lib (
          with inputs;
          [
            helpers
            { utils = utils.lib; }
            { hm = home-manager.lib; }
            self.lib
          ]
        );

        inherit (inputs.nixpkgs.lib) nixosSystem;

        specialArgs = _module.args;
      in
      {
        packages.${system} = import ./packages {
          inherit self inputs pkgs;
          inherit (inputs.nixpkgs) lib;
        };
        nixosConfigurations =
          let
            sharedModules = with inputs; [
              home-manager.nixosModules.home-manager
              niri.nixosModules.niri
              sops-nix.nixosModules.sops
            ];
          in
          {
            estradiol = nixosSystem {
              system = systems.x86_64-linux;
              inherit specialArgs;
              modules = [
                (_: {
                  inherit _module;
                  nixpkgs.overlays = defaultOverlays;
                  home-manager.users.jules.nixpkgs.overlays = defaultOverlays;
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
              modules = [
                ./hosts/progesterone
              ]
              ++ sharedModules;
            };
          };

        lib = import ./lib/default.nix {
          inherit (inputs.nixpkgs) lib;
        };

        overlays = import ./overlays {
          inherit inputs;
          inherit (self) packages;
          inherit (inputs.nixpkgs) lib;
        };
      }
    )
    // eachDefaultSystem (
      system:
      let
        pkgs = makePkgs system;
      in
      {
        devShells = import ./devShells.nix { inherit pkgs; };
      }
    );

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
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    julespkgs = {
      url = "/home/jules/000_dev/000_nix/packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim.url = "/home/jules/000_dev/000_nix/nvf_julesvim";
    ghostty.url = "github:ghostty-org/ghostty";
    emoji.url = "/home/jules/000_dev/000_nix/emoji-picker";
    nix-init.url = "github:nix-community/nix-init";
  };
}
