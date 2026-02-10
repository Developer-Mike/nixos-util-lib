# mk-system function for creating NixOS system configurations
{
  custom-options ? [],
  secrets ? null
}:

{
  nixpkgs,
  nixpkgs-alt,
  home-manager,
  inputs,

  system,
  version,
  hostname-owner ? null,
  systemname,
  users,
  system-module,

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
  specialArgs = args // {
    inherit hostname pkgs-alt;
  };
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

    # Custom options
    ({ ... }: {
      imports = custom-options;
    })

    # System module
    system-module

    # User system modules
    ({ ... }: {
      imports = users.map (user: user.system-module);
    })

    # Home Manager
    (import ./mk-home.nix { inherit home-manager version users specialArgs; })
  ] ++ (if inputs.agenix != null then [
    inputs.agenix.nixosModules.default
    secrets
  ] else []);
}
