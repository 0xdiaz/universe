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

  # No GPG/pass/SOPS secrets set up on this machine yet — see
  # nix/configurations/home/r17.nix for how to layer that back in later.
  # activation.nix (shared home module) unconditionally reads
  # config.sops.secrets.*, which doesn't exist without importing sops-nix;
  # disable its two scripts here rather than reintroducing sops.
  home.activation.importGpgKeys = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] "");
  home.activation.generateGitIdentities = lib.mkForce (lib.hm.dag.entryAfter [ "writeBoundary" ] "");

  # git.nix (shared home module) hardcodes r17x's identity and requires GPG
  # signing; override both for this machine.
  programs.git.userName = "Diaz";
  programs.git.userEmail = "0xliverdiaz@gmail.com";
  programs.git.extraConfig.commit.gpgSign = lib.mkForce false;
  programs.jujutsu.settings.user = lib.mkForce {
    name = "Diaz";
    email = "0xliverdiaz@gmail.com";
  };

  imports = lib.attrValues ezModules;
}
