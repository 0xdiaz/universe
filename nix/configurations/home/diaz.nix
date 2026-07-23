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
    ];
    sessionVariables.EDITOR = lib.getExe' inputs.self.packages.${pkgs.stdenv.system}.nvim "nvim";
    sessionVariables.CLAUDE_CODE_DISABLE_1M_CONTEXT = 1;
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
  programs.jujutsu.settings.user = {
    name = "Diaz";
    email = "0xliverdiaz@gmail.com";
  };

  imports = lib.attrValues ezModules;
}
