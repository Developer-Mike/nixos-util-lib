# mk-home function for creating Home Manager configurations
{ home-manager, specialArgs }:

{ version, user-paths }:

{ pkgs, ... }:

{
  imports = [
    home-manager.nixosModules.home-manager {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        # Loop through users and create ${user.username}: ${user.home-manager-user} mapping
        users = builtins.listToAttrs (map (user-path:
          let
            user = import user-path (specialArgs // { inherit pkgs; });
          in
          {
            name = user.username;
            value = user.home-manager-user // {
              _module.args = specialArgs // {
                inherit pkgs;
                user-secrets = user.secrets;
              };

              home = {
                username = user.username;
                homeDirectory = "/home/${user.username}";
                stateVersion = version;
              };
            };
          }
        ) user-paths);
      };
    }
  ];
}
