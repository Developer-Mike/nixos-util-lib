# mk-home function for creating Home Manager configurations
{ home-manager, version, users, specialArgs }:

{ lib, pkgs, ... }:
let
  extraSpecialArgs = specialArgs // {
    inherit pkgs;
  };
in
{
  imports = [
    home-manager.nixosModules.home-manager {
      home-manager = {
        inherit extraSpecialArgs;

        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        users = builtins.listToAttrs (map (user: {
            name = user.username;
            value = {
              import = [ user.home-manager-module ];

              home = {
                username = user.username;
                homeDirectory = "/home/${user.username}";
                stateVersion = version;
              };
            };
          }
        ) users);
      };
    }
  ];
}
