{
  lib,
  pkgs,
  ezModules,
  crossModules,
  config,
  ...
}:

{
  imports = lib.attrValues (ezModules // crossModules);

  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "diaz";

  users.users.diaz = {
    home = "/Users/diaz";
    shell = pkgs.fish;
  };

  # --- see: nix/nixosModules/nix.nix
  nix-settings = {
    enable = true;
    use = "full";
    inputs-to-registry = true;
  };

  # This machine's Nix was installed via the Determinate Systems installer,
  # which runs its own daemon — let it manage the Nix installation instead
  # of nix-darwin (nix.settings/registry above still apply via nix-settings).
  # gc/optimise require nix.enable, so disable those two (Determinate has
  # its own equivalents).
  nix.enable = false;
  nix.optimise.automatic = lib.mkForce false;
  nix.gc.automatic = lib.mkForce false;

  # --- nix-darwin
  homebrew.enable = true;
  # Don't uninstall Homebrew packages that aren't declared here yet (e.g. gh,
  # installed manually before this config existed).
  homebrew.onActivation.cleanup = lib.mkForce "none";
  # Mac App Store apps require a signed-in App Store account, not set up on
  # this machine yet; skip for now.
  homebrew.masApps = lib.mkForce { };

  networking = {
    hostName = lib.mkDefault "diaz";
    computerName = config.networking.hostName;
  };
}
