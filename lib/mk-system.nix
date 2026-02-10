# mk-system function for creating NixOS system configurations
{
  nixpkgs,
  nixpkgs-alt,
  home-manager,
  inputs,

  system,
  version,
  hostname-owner ? null,
  systemname,
  user-paths,
  os-path,

  ...
} @ args:

let
  hostname = if hostname-owner != null then
    "${hostname-owner}-${systemname}"
  else systemname;

  # Set pkgs
  pkgs-alt = import nixpkgs-alt {
    inherit system;
    config.allowUnfree = true;
  };

  # Shared arguments passed to all modules
  tmpSpecialArgs = args // {
    inherit hostname pkgs-alt;
  };

  # Import OS configuration
  os-configuration = import os-path tmpSpecialArgs;

  # Make final shared args with config
  specialArgs = tmpSpecialArgs // { system-config = os-configuration.config; };
in
nixpkgs.lib.nixosSystem
{
  inherit system specialArgs;

  modules = [
    # System configuration
    {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      system.stateVersion = version;

      networking.hostName = hostname;
      programs.zsh.enable = true;

      nixpkgs.config.allowUnfree = true;
    }

    # Users
    (import ./mk-users.nix { inherit specialArgs; })

    # Home Manager
    (import ./mk-home.nix { inherit home-manager version user-paths specialArgs; })
  ] ++ nixpkgs.lib.mkIf (inputs.agenix != null) [
    inputs.agenix.nixosModules.default
  ] ++ os-configuration.system;
}
