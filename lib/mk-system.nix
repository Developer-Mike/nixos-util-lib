# mk-system function for creating NixOS system configurations
{
  hardware-configuration,
  nixpkgs,
  nixpkgs-stable,
  home-manager,

  system,
  version,
  hostname-owner,
  systemname,
  user-paths,
  os-path,

  ...
} @ args:

let
  hostname = "${hostname-owner}-${systemname}";

  # Set pkgs
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };

  # Shared arguments passed to all modules
  tmpSpecialArgs = args // {
    inherit hostname pkgs-stable;
  };

  # Import OS configuration
  os-configuration = import os-path tmpSpecialArgs;

  # Make final shared args with secrets
  specialArgs = tmpSpecialArgs // { system-secrets = os-configuration.secrets; };
in
nixpkgs.lib.nixosSystem
{
  inherit system specialArgs;

  modules = [
    # Hardware configuration
    hardware-configuration

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
  ] ++ os-configuration.system;
}
