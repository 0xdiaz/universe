{
  lib,
  inputs,
  ...
}:

{

  imports = [
    inputs.process-compose-flake.flakeModule
    inputs.ez-configs.flakeModule

    ./devShells.nix
    ./overlays
    ./nvim.nix

    ./modules/flake/module-config.nix
    {
      modulesGen.flakeModules.dir = ./modules/flake;
      modulesGen.crossModules.dir = ./modules/cross;
      modulesGen.nixvimModules.dir = ./nvim.nix/config;
    }

    ./modules/flake/rebuild-script.nix
    {
      rebuild-scripts.enable = true;
    }

    ./modules/flake/universe.nix

    ./modules/flake/pkgs-by-name.nix
    {
      perSystem.pkgsDirectory = ./packages;
      perSystem.pkgsNameSeparator = ".";
    }
  ];

  flake = {

    # --- shareable nixpkgs configurations
    nixpkgs = {
      config = {
        allowBroken = true;
        allowUnfree = true;
        tarball-ttl = 0;
        contentAddressedByDefault = false;
      };

      overlays = lib.attrValues inputs.self.overlays ++ [
        inputs.ocaml-nvim.overlays.default
      ];
    };

    icons = import ./icons.nix;
    colors = import ./colors.nix { inherit lib; };
    color = inputs.self.colors.mkColor inputs.self.colors.lists.edge;
  };

  ezConfigs = {
    root = ./.;
    globalArgs = {
      inherit (inputs) self;
      inherit inputs;
      inherit (inputs.self)
        icons
        colors
        color
        crossModules
        ;
    };

    home.modulesDirectory = ./modules/home;
    home.configurationsDirectory = ./configurations/home;

    darwin.modulesDirectory = ./modules/darwin;
    darwin.configurationsDirectory = ./configurations/darwin;
    darwin.hosts = {
      diaz.userHomeModules = [ "diaz" ];
    };
  };

  perSystem =
    {
      pkgs,
      system,
      inputs',
      ...
    }:
    {
      formatter = inputs'.nixpkgs.legacyPackages.nixfmt-rfc-style;

      process-compose."ai" = {
        imports = [
          inputs.services-flake.processComposeModules.default
        ];
        services.ollama.ollamaX.enable = true;
        services.ollama.ollamaX.dataDir = "$HOME/.process-compose/ai/data/ollamaX";
        services.ollama.ollamaX.models = [ "deepseek-r1:1.5b" ];
      };

      # just for demo - https://x.com/dhh/status/1897982683772317776
      process-compose."mysql" = {
        imports = [
          inputs.services-flake.processComposeModules.default
        ];
        services.mysql."m1" = {
          enable = true;
          package = pkgs.mariadb_114;
          settings.mysqld.port = 3307;
        };
        services.mysql."m2" = {
          enable = true;
          package = pkgs.mariadb_105;
          settings.mysqld.port = 3308;
        };
        services.mysql."m3" = {
          enable = true;
          package = pkgs.mariadb_106;
          settings.mysqld.port = 3309;
        };
      };

      _module.args = {
        inherit (inputs.self) icons colors color;
        extraModuleArgs = {
          inherit (inputs.self) icons colors color;
        };
        pkgs = import inputs.nixpkgs {
          inherit system;
          inherit (inputs.self.nixpkgs) config overlays;
        };
      };
    };
}
