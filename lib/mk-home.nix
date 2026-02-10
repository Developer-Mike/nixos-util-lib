# mk-home function for creating Home Manager configurations
{ home-manager, version, user-options, users, specialArgs }:

{ lib, pkgs, ... }:

{
  imports = [
    home-manager.nixosModules.home-manager

    {
      home-manager = {
        extraSpecialArgs = specialArgs // {
          inherit pkgs;
        };

        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        users = builtins.listToAttrs (map (user-path:
          let
            user = import user-path;
          in {
            name = user.username;
            value = {
              imports = [ user-options user.home-manager-module ];

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
