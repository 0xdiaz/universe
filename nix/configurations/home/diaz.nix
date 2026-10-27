{
  inputs,
  lib,
  pkgs,
  ezModules,
  osConfig ? { },
  ...
}:

{
  home = rec {
    username = "diaz";
    stateVersion = "25.05";
    homeDirectory = osConfig.users.users.${username}.home or "/Users/${username}";
    packages = [
      inputs.self.packages.${pkgs.stdenv.system}.nvim
      inputs.self.packages.${pkgs.stdenv.system}.universe
      pkgs.claude-code

      # Go
      pkgs.go

      # Rust (separate nixpkgs pin, see flake.nix nixpkgs-rust)
      pkgs.branches.rust.rustc
      pkgs.branches.rust.cargo
      pkgs.branches.rust.rustfmt
      pkgs.branches.rust.clippy

      # TypeScript / Next.js / Nest.js (Bun is the primary runtime)
      pkgs.bun
      # nodejs is only here for `npx`, which the playwright and context7
      # MCP servers invoke directly. Not for project work -- use bun.
      pkgs.nodejs

      # Solidity
      pkgs.foundry
      pkgs.solc

      # Flutter
      pkgs.flutterPackages.stable
    ] ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.cocoapods ];
    sessionVariables.EDITOR = lib.getExe' inputs.self.packages.${pkgs.stdenv.system}.nvim "nvim";
    sessionVariables.CLAUDE_CODE_DISABLE_1M_CONTEXT = 1;
    sessionPath = [
      "$HOME/go/bin"
      "$HOME/.cargo/bin"
      # uv/uvx and the serena MCP server install here
      "$HOME/.local/bin"
    ];
  };

  programs.terminal.use = "ghostty";

  # rtk's crates.io vendor fetch gets 403'd from this network; revisit later.
  universeHostPackages.excludeRtk = true;

  # No GPG/pass/SOPS secrets set up on this machine yet.

  # git.nix (shared home module) forces GPG commit signing on; override for
  # this machine since no GPG identity is set up.
  programs.git.userName = "Diaz";
  programs.git.userEmail = "0xliverdiaz@gmail.com";
  programs.git.extraConfig.commit.gpgSign = lib.mkForce false;

  # Work identity (github account diaz-onetrade) for everything under
  # ~/dev/onetrade. Default above stays personal; the trailing slash makes the
  # condition match the directory's contents recursively.
  programs.git.includes = [
    {
      condition = "gitdir:~/dev/onetrade/";
      contents.user = {
        name = "Diaz Permana";
        email = "diaz.permana@onetrade.id";
      };
    }
  ];
  programs.jujutsu.settings.user = {
    name = "Diaz";
    email = "0xliverdiaz@gmail.com";
  };

  imports = lib.attrValues ezModules;
}
